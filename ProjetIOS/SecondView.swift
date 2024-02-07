//
//  SecondView.swift
//  ProjetIOS
//
//  Created by Justin SOTTILE & Gauthier MIGUET on 07/02/2024.
//

import Foundation
import SwiftUI

struct SecondView: View {
    @State private var searchText: String = ""
    @State private var cities: [City] = []
    
    var body: some View {

        NavigationView {
            VStack {
                SearchBar(text: $searchText, onSearch: fetchCities)
                
                List(cities) { city in
                    NavigationLink(destination: CityView(viewModel: CityViewModel(), city: city)) {
                        VStack(alignment: .leading) {
                                                Text(city.name)
                                                    .font(.headline)
                                                Text(city.country)
                                                    .font(.subheadline)
                                                    .foregroundColor(.secondary)
                                            }
                    }
                }
                .scrollContentBackground(.hidden)
                .listStyle(PlainListStyle())
                .navigationTitle(Text("All Cities"))
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            fetchCities()
        }
        
    }
    
    
    func fetchCities() {
            Task {
                do {
                    if searchText.isEmpty {
                        cities = try await defaultfetch()
                    } else {
                        cities = try await secondfetch(for: searchText)
                    }
                } catch {
                    print("Error fetching cities: \(error)")
                }
            }
        }
        
        func secondfetch(for placeName: String) async throws -> [City] {
            guard let url = URL(string: "https://geocoding-api.open-meteo.com/v1/search?name=\(placeName)&count=10&language=fr&format=json") else {
                print("Invalid URL")
                throw ErrorPerso.invalidURL
            }
            
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                
                // Decode the top-level JSON as a dictionary
                guard let topLevelJSON = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                    throw ErrorPerso.decodingFailed
                }
                
                // Extract the array of cities from the "results" key
                guard let results = topLevelJSON["results"] as? [[String: Any]] else {
                    throw ErrorPerso.decodingFailed
                }
                
                // Decode each city individually, skipping items with missing or unexpected keys
                var decodedCities: [City] = []
                for result in results {
                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: result, options: [])
                        let decodedCity = try JSONDecoder().decode(City.self, from: jsonData)
                        decodedCities.append(decodedCity)
                    } catch {
                        print("Error decoding city:", error)
                    }
                }
                return decodedCities
            } catch {
                print("Error fetching cities:", error)
                throw error
            }
        }

    func defaultfetch() async throws -> [City] {
        var allCities: [City] = []
        
        let placeNames = ["Paris","New York", "Barcelone","Rome", "Berlin","Marseille", "Bordeaux"]
        for placeName in placeNames {
            guard let url = URL(string: "https://geocoding-api.open-meteo.com/v1/search?name=\(placeName)&count=1&language=fr&format=json") else {
                print("Invalid URL")
                throw ErrorPerso.invalidURL
            }
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                let topLevelJSON = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                
                if let results = topLevelJSON?["results"] as? [[String: Any]] {
                    // Convert the array of dictionaries to JSON data
                    let jsonData = try JSONSerialization.data(withJSONObject: results, options: [])
                    // Decode the array of City from the new JSON data
                    let decodedCities = try JSONDecoder().decode([City].self, from: jsonData)
                    allCities.append(contentsOf: decodedCities)
                } else {
                    throw ErrorPerso.decodingFailed
                    // Decode each city individually, skipping items with missing or unexpected keys
                }
            } catch {
                print("Error fetching cities:", error)
                throw error
            }
        }
        
        return allCities
    }


}

