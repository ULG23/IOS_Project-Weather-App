//
//  Extensions.swift
//  ProjetIOS
//
//  Created by Gauthier MIGUET on 06/02/2024.
//

import Foundation
import SwiftUI


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
extension Date {
    func formattedDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy--HH:mm"
        return dateFormatter.string(from: self)
    }
}

extension Float {
    func roundDouble() -> String {
        return String(format: "%.0f", self)
    }
}

extension DateFormatter {
    static let apiDateFormatCurrent: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
}

extension DateFormatter {
    static let apiDateFormatDaily: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
}

extension Float {
    func minutesToHoursMinutes() -> (hours: Int, minutes: Int) {
        let totalMinutes = Int(self)
        return (totalMinutes / 60, totalMinutes % 60)
    }
}
