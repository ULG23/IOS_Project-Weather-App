//
//  WeatherConditionView.swift
//  ProjetIOS
//
//  Created by Justin SOTTILE & Gauthier MIGUET on 07/02/2024.
//

import Foundation
import SwiftUI


struct WeatherConditionView: View {
    let weatherCode: Float
    
    var body: some View {
        VStack(spacing: 20) {

            
            Text("Actually")
                .font(.system(size: 20))
                .fontWeight(.bold)
                .padding()
            
            Spacer()
            
            Image(systemName: weatherSymbolName)
                .font(.system(size: 40))
        }
        .frame(width: 150, alignment: .leading)
    }
    
    private var weatherSymbolName: String {
        switch weatherCode {
        case 0:
            return "sun.max"
        case 1, 2, 3:
            return "cloud.sun"
        case 45, 48:
            return "cloud.fog"
        case 51, 53, 55:
            return "cloud.drizzle"
        case 56, 57:
            return "cloud.drizzle.fill"
        case 61, 63, 65:
            return "cloud.rain"
        case 66, 67:
            return "cloud.sleet"
        case 71, 73, 75:
            return "cloud.snow"
        case 77:
            return "cloud.snow.fill"
        case 80, 81, 82:
            return "cloud.sun.rain"
        case 85, 86:
            return "cloud.snow"
        case 95:
            return "cloud.bolt"
        case 96, 99:
            return "cloud.bolt.rain"
        default:
            return "questionmark"
        }
    }
}
