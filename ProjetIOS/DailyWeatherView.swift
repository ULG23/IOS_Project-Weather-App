//
//  DailyWeatherView.swift
//  ProjetIOS
//
//  Created by Justin SOTTILE & Gauthier MIGUET on 07/02/2024.
//

import Foundation
import SwiftUI


struct DailyWeatherView: View {
    var index: Int
    var weatherForecast: WeatherData?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let date = weatherForecast?.daily.time[index] {
                Text("Weather for \(formattedDate(date: date))")
                    .bold()
                    .padding(.bottom)
            }
            
            HStack {
                WeatherRow(logo: "thermometer", name: "Temperature Max", value: "\(weatherForecast?.daily.temperature_2m_max[index].roundDouble() ?? "0")°")
                Spacer()
                WeatherRow(logo: "cloud.rain", name: "Rain", value: "\(weatherForecast?.daily.rain_sum[index].roundDouble() ?? "0")%")
            }
            
            HStack {
                WeatherRow(logo: "wind", name: "Wind Max Speed", value: "\(weatherForecast?.daily.wind_speed_10m_max[index].roundDouble() ?? "0") m/s")
                Spacer()
                WeatherRow(logo: "sun.horizon.fill", name: "Sunshine Duration", value: {
                    let sunshineDurationInSeconds = weatherForecast?.daily.sunshine_duration[index] ?? 0
                    let convertedDuration = Float(sunshineDurationInSeconds).secondsToHoursMinutes()
                    
                    return "\(convertedDuration.hours)h \(convertedDuration.minutes)min"
                }())
            }
        }
        .padding()
    }
    
    private func formattedDate(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM"
        return dateFormatter.string(from: date)
    }
}

