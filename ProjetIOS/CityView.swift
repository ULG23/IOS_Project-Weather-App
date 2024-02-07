//
//  CityView.swift
//  ProjetIOS
//
//  Created by Justin SOTTILE & Gauthier MIGUET on 05/02/2024.
//
import Foundation
import SwiftUI

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
                self.isFetchingWeather = false
            }
        } catch {
            await MainActor.run {
                errorMessage = "Failed to fetch weather data: \(error.localizedDescription)"
                self.isFetchingWeather = false 
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
                    .frame(maxHeight: .infinity)
                    .padding()
                
                Spacer(minLength: 0)
                
                Text("Actual Temperature: \(viewModel.weatherForecast?.current.temperature_2m.roundDouble() ?? "0")°")
                    .font(.system(size: 20))
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .padding()
                    .frame(maxWidth: .infinity)
            }
            
            
            AsyncImageView(url: URL(string: "https://cdn.pixabay.com/photo/2020/04/18/01/04/cityscape-5057263_1280.png"))
                .frame(width: 400, height: 200)
                .mask(LinearGradient(gradient: Gradient(stops: [
                            .init(color: .black, location: 0),
                            .init(color: .clear, location: 1),
                            .init(color: .black, location: 1),
                            .init(color: .clear, location: 1)
                        ]), startPoint: .top, endPoint: .bottom))
                .clipShape(Circle())
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
