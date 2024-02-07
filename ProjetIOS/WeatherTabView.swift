//
//  WeatherTabView.swift
//  ProjetIOS
//
//  Created by Gauthier MIGUET on 07/02/2024.
//

import Foundation
import SwiftUI

struct WeatherTabView: View {
    @ObservedObject var viewModel: CityViewModel
    
    var body: some View {
        TabView {
            ForEach(viewModel.weatherForecast?.daily.time.indices ?? 0..<0, id: \.self) { index in
                DailyWeatherView(index: index, weatherForecast: viewModel.weatherForecast)
                    .padding()
                    .tag(index)
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
        .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
        .frame(height: 200)
        .background(Color(hue: 0.656, saturation: 0.787, brightness: 0.354))

    }
}

