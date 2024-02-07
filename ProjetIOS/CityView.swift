//
//  CityView.swift
//  ProjetIOS
//
//  Created by Gauthier MIGUET on 05/02/2024.
//
import Foundation
import SwiftUI

struct WeatherData: Decodable {
    let latitude: Double
    let longitude: Double
    let generationtime_ms: Double
    let utc_offset_seconds: Int
    let timezone: String
    let timezone_abbreviation: String
    let elevation: Double
    
    let current: Current
    let daily: Daily

    struct Current: Decodable {
        let time: Date
        let temperature_2m: Float

        private enum CodingKeys: String, CodingKey {
            case time, temperature_2m
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let timeString = try container.decode(String.self, forKey: .time)

            guard let time = DateFormatter.apiDateFormatCurrent.date(from: timeString) else {
                throw DecodingError.dataCorruptedError(forKey: .time, in: container, debugDescription: "Invalid date format")
            }
            self.time = time
            self.temperature_2m = try container.decode(Float.self, forKey: .temperature_2m)
        }
    }



    struct Daily: Decodable {
        let time: [Date]
        let weather_code: [Int]
        let temperature_2m_max: [Float]
        let temperature_2m_min: [Float]
        let sunshine_duration: [Float]
        let precipitation_sum: [Float]
        let rain_sum: [Float]
        let precipitation_probability_max: [Float]
        let wind_speed_10m_max: [Float]

        private enum CodingKeys: String, CodingKey {
            case time, weather_code, temperature_2m_max, temperature_2m_min, sunshine_duration, precipitation_sum, rain_sum, precipitation_probability_max, wind_speed_10m_max
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let timeStrings = try container.decode([String].self, forKey: .time)
            time = try timeStrings.map { dateString in
                guard let date = DateFormatter.apiDateFormatDaily.date(from: dateString) else {
                    throw DecodingError.dataCorruptedError(forKey: .time, in: container, debugDescription: "Invalid date format")
                }
                return date
            }
            weather_code = try container.decode([Int].self, forKey: .weather_code)
            temperature_2m_max = try container.decode([Float].self, forKey: .temperature_2m_max)
            temperature_2m_min = try container.decode([Float].self, forKey: .temperature_2m_min)
            sunshine_duration = try container.decode([Float].self, forKey: .sunshine_duration)
            precipitation_sum = try container.decode([Float].self, forKey: .precipitation_sum)
            rain_sum = try container.decode([Float].self, forKey: .rain_sum)
            precipitation_probability_max = try container.decode([Float].self, forKey: .precipitation_probability_max)
            wind_speed_10m_max = try container.decode([Float].self, forKey: .wind_speed_10m_max)
        }
    }
}

class CityViewModel: ObservableObject {
    @Published var weatherForecast: WeatherData?
    @Published var isFetchingWeather = false
    @Published var errorMessage: String?
    
    
    func fetchCityWeather(latitude: Double, longitude: Double) async {
        await MainActor.run { isFetchingWeather = true }
        
        do {
            let weather = try await fetchWeatherData(latitude: latitude, longitude: longitude)
            
            await MainActor.run {
                self.weatherForecast = weather
                self.isFetchingWeather = false // Move isFetchingWeather update here
            }
        } catch {
            await MainActor.run {
                errorMessage = "Failed to fetch weather data: \(error.localizedDescription)"
                self.isFetchingWeather = false // Also set isFetchingWeather to false here
            }
        }
    }
    
    func fetchWeatherData(latitude: Double, longitude: Double) async throws -> WeatherData {
        let urlString = "https://api.open-meteo.com/v1/forecast?latitude=\(latitude)&longitude=\(longitude)&current=temperature_2m&daily=weather_code,temperature_2m_max,temperature_2m_min,sunshine_duration,precipitation_sum,rain_sum,precipitation_probability_max,wind_speed_10m_max&format=json"
        guard let url = URL(string: urlString) else {
            throw ErrorPerso.invalidURL
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let temp = try JSONDecoder().decode(WeatherData.self, from: data)
            return temp
        } catch {
            // Assuming you want to print or log the error before throwing it
            print("Error fetching city weather: \(error)")
            throw ErrorPerso.fetchFailed
        }
    }
}

struct CityView: View {
    @ObservedObject var viewModel: CityViewModel
    @State private var isCityAdded: Bool = false
    @EnvironmentObject var addedcity: AddedCities
    
    
    var city: City
    
    var body: some View {
          ZStack(alignment: .leading) {
              VStack {
                  VStack(alignment: .leading, spacing: 5) {
                      Text(city.name)
                          .bold()
                          .font(.title)
                      
                      Text("Today, \(Date().formatted(.dateTime.month().day().hour().minute()))")
                          .fontWeight(.light)
                  }
                  .frame(maxWidth: .infinity, alignment: .leading)
                  
                  Spacer()
                  
                  VStack {
                      HStack {
                          VStack(spacing: 20) {
                              Image(systemName: "cloud")
                                  .font(.system(size: 40))
                              
                              Text("WeatherCondition")
                          }
                          .frame(width: 150, alignment: .leading)
                          
                          Spacer()
                          
                          Text("Actual Temperature: \(viewModel.weatherForecast?.current.temperature_2m.roundDouble() ?? "0")°")
                              .font(.system(size: 20))
                              .fontWeight(.bold)
                              .padding()
                      }
                      
                      Spacer()
                          .frame(height:  80)
                      
                      AsyncImage(url: URL(string: "https://cdn.pixabay.com/photo/2020/01/24/21/33/city-4791269_960_720.png")) { image in
                          image
                              .resizable()
                              .aspectRatio(contentMode: .fit)
                              .frame(width: 350)
                      } placeholder: {
                          ProgressView()
                      }
                      
                      Spacer()
                  }
                  .frame(maxWidth: .infinity, alignment: .trailing)
              }
              .padding()
              .frame(maxWidth: .infinity, alignment: .leading)
              
              VStack {
                  Spacer()
                  VStack(alignment: .leading, spacing: 20) {
                      Text("Weather now")
                          .bold()
                          .padding(.bottom)
                      
                      HStack {
                          WeatherRow(logo: "thermometer", name: "Temperature Max", value: "\(viewModel.weatherForecast?.daily.temperature_2m_max.first?.roundDouble() ?? "0")°")
                          Spacer()
                          WeatherRow(logo: "cloud.rain", name: "Rain", value: "\(viewModel.weatherForecast?.daily.rain_sum.first?.roundDouble() ?? "0")%")
                      }
                      
                      HStack {
                          WeatherRow(logo: "wind", name: "Wind Max Speed", value: "\(viewModel.weatherForecast?.daily.wind_speed_10m_max.first?.roundDouble() ?? "0") m/s")
                          Spacer()
                          WeatherRow(logo: "sun.horizon.fill", name: "Sunshine Duration", value: {
                              let sunshineDurationInMinutes = viewModel.weatherForecast?.daily.sunshine_duration.first ?? 0
                              let convertedDuration = sunshineDurationInMinutes.minutesToHoursMinutes()
                              
                              return "\(convertedDuration.hours)h \(convertedDuration.minutes)min"
                          }())
                      }
                  }
                  .frame(maxWidth: .infinity, alignment: .leading)
                  .padding()
                  .padding(.bottom, 20)
                  .foregroundColor(Color(hue: 0.656, saturation: 0.787, brightness: 0.354))
                  .background(.white)
              }
          }
          .edgesIgnoringSafeArea(.bottom)
          .background(Color(hue: 0.656, saturation: 0.787, brightness: 0.354))
          .preferredColorScheme(.dark)
        .onAppear {
            Task {
                await viewModel.fetchCityWeather(latitude: city.latitude, longitude: city.longitude);
                isCityAdded = addedcity.addedCities.firstIndex(where: { $0.id == city.id }) != nil ? true : false
            }
        }.navigationBarItems(trailing: Button(action: {
            if !isCityAdded {
                //addedcity.addedCities.append("\(city.name): Lat \(city.latitude), Lon \(city.longitude)")
                addedcity.addedCities.append(city)
                isCityAdded.toggle()
            } else {
                // Optionally, remove the city if it's already added
                //if let index = addedcity.addedCities.firstIndex(of: "\(city.name): Lat \(city.latitude), Lon \(city.longitude)") {
                if let index = addedcity.addedCities.firstIndex(where: { $0.id == city.id }) {
                    addedcity.addedCities.remove(at: index)
                    isCityAdded.toggle()
                }

            }
            print("Top-right button tapped")
        }) {
            Text(isCityAdded ? "Remove from List" : "Add to List")
                .foregroundColor(.blue)
        
        })
    }
    
    private func formattedDate(from timestamp: String) -> String {
          guard let date = convertToDate(timestamp: timestamp) else { return "" }
          return date.formattedDate()
      }

}


private func convertToDate(timestamp: String) -> Date? {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
    return dateFormatter.date(from: timestamp)
}
