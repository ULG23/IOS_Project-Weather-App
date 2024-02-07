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
        let weather_code: Float

        private enum CodingKeys: String, CodingKey {
            case time, temperature_2m, weather_code
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let timeString = try container.decode(String.self, forKey: .time)

            guard let time = DateFormatter.apiDateFormatCurrent.date(from: timeString) else {
                throw DecodingError.dataCorruptedError(forKey: .time, in: container, debugDescription: "Invalid date format")
            }
            self.time = time
            self.temperature_2m = try container.decode(Float.self, forKey: .temperature_2m)
            self.weather_code = try container.decode(Float.self, forKey: .weather_code)
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
        let urlString = "https://api.open-meteo.com/v1/forecast?latitude=\(latitude)&longitude=\(longitude)&current=temperature_2m,weather_code&daily=weather_code,temperature_2m_max,temperature_2m_min,sunshine_duration,precipitation_sum,rain_sum,precipitation_probability_max,wind_speed_10m_max&format=json"
        guard let url = URL(string: urlString) else {
            throw ErrorPerso.invalidURL
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            return try JSONDecoder().decode(WeatherData.self, from: data)
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
    @EnvironmentObject var addedCity: AddedCities
    
    var city: City
    
    var body: some View {
        VStack(spacing: 0) {
            // Upper part of the view
            HeaderView(city: city, isCityAdded: $isCityAdded, addedCity: addedCity, viewModel: viewModel)
            
            // Content
            ContentCityView(viewModel: viewModel)
            
            // TabView at the bottom
            WeatherTabView(viewModel: viewModel)
        }
        .edgesIgnoringSafeArea(.bottom)
        .onAppear {
            Task {
                await viewModel.fetchCityWeather(latitude: city.latitude, longitude: city.longitude)
                isCityAdded = addedCity.addedCities.contains { $0.id == city.id }
            }
        }
    }
}


struct ContentCityView: View {
    @ObservedObject var viewModel: CityViewModel
    
    var body: some View {
        VStack {
            HStack {
                WeatherConditionView(weatherCode: viewModel.weatherForecast?.current.weather_code ?? 0.0)
                Spacer()
                
                Text("Actual Temperature: \(viewModel.weatherForecast?.current.temperature_2m.roundDouble() ?? "0")°")
                    .font(.system(size: 20))
                    .fontWeight(.bold)
                    .padding()
                    .multilineTextAlignment(.center)
            }
            
            Spacer().frame(height: 50)
            
            AsyncImageView(url: URL(string: "https://cdn.pixabay.com/photo/2020/04/18/01/04/cityscape-5057263_1280.png")).frame(maxHeight: 200)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
        .background(Color(hue: 0.656, saturation: 0.787, brightness: 0.354))
    }
}

struct AddRemoveButton: View {
    @Binding var isCityAdded: Bool
    @EnvironmentObject var addedCity: AddedCities 
    var city: City

    var body: some View {
        Button(action: {
            if !isCityAdded {
                addedCity.addedCities.append(city)
                isCityAdded.toggle()
            } else {
                if let index = addedCity.addedCities.firstIndex(where: { $0.id == city.id }) {
                    addedCity.addedCities.remove(at: index)
                    isCityAdded.toggle()
                }
            }
        }) {
            Text(isCityAdded ? "Remove from List" : "Add to List")
                .foregroundColor(.blue)
        }
    }
}



private func formattedDate(from timestamp: String) -> String {
      guard let date = convertToDate(timestamp: timestamp) else { return "" }
      return date.formattedDate()
  }




private func convertToDate(timestamp: String) -> Date? {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
    return dateFormatter.date(from: timestamp)
}
