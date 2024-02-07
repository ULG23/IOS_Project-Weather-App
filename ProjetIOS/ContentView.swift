//
//  ContentView.swift
//  ProjetIOS
//
//  Created by Justin SOTTILE & Gauthier MIGUET on 02/02/2024.
//

import SwiftUI

struct ContentView: View {
    @State private var isSecondViewPresented = false
    @EnvironmentObject var favorite: AddedCities

    var body: some View {
        NavigationView {
            ZStack {
                // Background Image
                AsyncImageView(url: URL(string: "https://images.unsplash.com/photo-1436891620584-47fd0e565afb?q=80&w=3087&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D"))
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)
                    .opacity(0.6) // Adjust opacity as needed
                    .mask(LinearGradient(gradient: Gradient(stops: [
                                .init(color: .black, location: 0),
                                .init(color: .clear, location: 1),
                                .init(color: .black, location: 1),
                                .init(color: .clear, location: 1)
                            ]), startPoint: .bottom, endPoint: .top))

                VStack {
                    Text("Favorite Cities")
                        .padding()
                        .foregroundColor(Color.white)
                        .font(.headline)

                    Spacer()

                    NavigationLink(
                        destination: SecondView(),
                        isActive: $isSecondViewPresented,
                        label: {
                            EmptyView()
                        })

                    if favorite.addedCities.isEmpty {
                        VStack {
                            Spacer()
                            Text("No cities added yet")
                                .foregroundColor(.secondary)
                                .padding()
                            Spacer()
                        }
                    } else{
                        // List with background color
                        List {
                            ForEach(favorite.addedCities) { city in
                                
                                    NavigationLink(destination: CityView(viewModel: CityViewModel(), city: city)) {
                                        Text(city.name)
                                            .foregroundColor(.white)
                                            .font(.headline)
                                        Text(city.country)
                                            .foregroundColor(.secondary)
                                    }.padding(7)
                                    
                                 
                                
                            }.listRowBackground(
                                Capsule()
                                    .fill(Color.gray)
                                    .padding(2)
                            )
                        }
                  
                        //.padding(20)
                        .scrollContentBackground(.hidden)
                    }
                }
            }
            .navigationBarItems(trailing: Button(action: {
                // Button action to present the SecondView
                isSecondViewPresented = true
            }, label: {
                HStack {
                    Text("add cities")
                        .foregroundColor(Color.blue)
                    Image(systemName: "chevron.right")
                        .imageScale(.large)
                        .foregroundColor(Color.blue)
                }
            }))
            .navigationBarTitle("Météo", displayMode: .inline)
            .foregroundColor(Color(hue: 0.656, saturation: 0.787, brightness: 0.354))
            .preferredColorScheme(.dark)
        }
    }
}







enum ErrorPerso: Error {
    case invalidURL
    case decodingFailed
    case fetchFailed
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        SecondView()
    }
}
