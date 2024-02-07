//
//  HeaderView.swift
//  ProjetIOS
//
//  Created by Gauthier MIGUET on 07/02/2024.
//

import Foundation
import SwiftUI


struct HeaderView: View {
    var city: City
    @Binding var isCityAdded: Bool
    @ObservedObject var addedCity: AddedCities
    @ObservedObject var viewModel: CityViewModel
    
    var body: some View {
        ZStack(alignment: .leading) {
            VStack(alignment: .leading, spacing: 5) {
                Text(city.name)
                    .bold()
                    .font(.title)
                
                Text("Today, \(Date().formatted(.dateTime.month().day().hour().minute()))")
                    .fontWeight(.light)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer()
            
        }
        .background(Color(hue: 0.656, saturation: 0.787, brightness: 0.354))
        .preferredColorScheme(.dark)
        .navigationBarItems(trailing: AddRemoveButton(isCityAdded: $isCityAdded, city: city))
    }
}
