//
//  StructWeatherData.swift
//  ProjetIOS
//
//  Created by Justin SOTTILE & Gauthier MIGUET on 07/02/2024.
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
