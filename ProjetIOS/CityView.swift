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
    
    let hourly_units: HourlyUnits
    let hourly: HourlyData
    
    struct HourlyUnits: Decodable {
        let time: String
        let temperature_2m: String
        let relative_humidity_2m: String
        let precipitation_probability: String
        let rain: String
        let showers: String
        let surface_pressure: String
        let wind_speed_10m: String
    }
    
    struct HourlyData: Decodable {
        let time: [String]
        let temperature_2m: [Float]
        let relative_humidity_2m: [Int]
        let precipitation_probability: [Int]
        let rain: [Float]
        let showers: [Float]
        let surface_pressure: [Float]
        let wind_speed_10m: [Float]
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
        let urlString = "https://api.open-meteo.com/v1/forecast?latitude=\(latitude)&longitude=\(longitude)&hourly=temperature_2m,relative_humidity_2m,precipitation_probability,rain,showers,surface_pressure,wind_speed_10m&forecast_days=1&format=json"
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
    @State private var addedCities: [String] = []
    var city: City
    
    var body: some View {
        VStack {
            Text(city.name)
                .font(.title)
                .padding()
            
            if viewModel.isFetchingWeather {
                ProgressView()
            }
            
            if let errorMessage = viewModel.errorMessage {
                Text("Error: \(errorMessage)")
                    .foregroundColor(.red)
            }
            
            // Display weather data if available
            if let weather = viewModel.weatherForecast {
                ScrollView {
                    LazyVStack {
                        ForEach(weather.hourly.time.indices, id: \.self) { index in
                            displayWeatherData(index: index, weather: weather.hourly)
                                .padding()
                                .background(Color.gray)
                                .cornerRadius(10)
                                .shadow(radius: 5)
                                .padding(.horizontal)
                        }
                    }
                }
            }
        }
        .onAppear {
            Task {
                await viewModel.fetchCityWeather(latitude: city.latitude, longitude: city.longitude)
            }
        }.navigationBarItems(trailing: Button(action: {
            // Handle button tap for the top-right "Add" button
            // You can perform any action here
            if !isCityAdded {
                addedCities.append("\(city.name): Lat \(city.latitude), Lon \(city.longitude)")
                isCityAdded.toggle()
            } else {
                // Optionally, remove the city if it's already added
                if let index = addedCities.firstIndex(of: "\(city.name): Lat \(city.latitude), Lon \(city.longitude)") {
                    addedCities.remove(at: index)
                    isCityAdded.toggle()
                }
            print("Top-right button tapped")
            // Optionally, you can use the addedCities array as needed
        }) {
            Text(isCityAdded ? "Remove from List" : "Add to List")
                .foregroundColor(.blue)
        
        })
        })
    }
    
    private func displayWeatherData(index: Int, weather: WeatherData.HourlyData) -> some View {
        VStack(alignment: .leading) {
            Text(weather.time.indices.contains(index) ? weather.time[index] : "")
                .font(.headline)
            
            if index < weather.temperature_2m.count {
                Text("Temperature: \(String(format: "%.1f", weather.temperature_2m[index]))°C")
            }
            if index < weather.relative_humidity_2m.count {
                Text("Relative Humidity: \(weather.relative_humidity_2m[index])%")
            }
            if index < weather.precipitation_probability.count {
                Text("Precipitation Probability: \(weather.precipitation_probability[index])%")
            }
            if index < weather.rain.count {
                Text("Rain: \(String(format: "%.1f", weather.rain[index])) mm")
            }
            if index < weather.showers.count {
                Text("Showers: \(String(format: "%.1f", weather.showers[index])) mm")
            }
            if index < weather.surface_pressure.count {
                Text("Surface Pressure: \(String(format: "%.1f", weather.surface_pressure[index])) hPa")
            }
            if index < weather.wind_speed_10m.count {
                Text("Wind Speed: \(String(format: "%.1f", weather.wind_speed_10m[index])) m/s")
            }
        }
    }
}

    
    struct WeatherInfoRow: View {
        var title: String
        var value: String
        
        var body: some View {
            HStack {
                Text(title)
                Spacer()
                Text(value)
            }
        }
    }
    
    extension Array where Element: Any {
        func element(at index: Int) -> Element? {
            return indices.contains(index) ? self[index] : nil
        }
    }
    
    extension Float {
        func formattedTemperature() -> String {
            return String(format: "%.1f", self) + "°"
        }
        
        func formattedRain() -> String {
            return String(format: "%.1f", self)
        }
        
        func formattedPressure() -> String {
            return String(format: "%.2f", self)
        }
        
        func formattedWindSpeed() -> String {
            return String(format: "%.1f", self)
        }
    }
    
