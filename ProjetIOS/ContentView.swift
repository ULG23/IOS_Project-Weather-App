//
//  ContentView.swift
//  ProjetIOS
//
//  Created by justin sottile on 02/02/2024.
//

import SwiftUI

struct ContentView: View {
    @State private var isSecondViewPresented = false
    @EnvironmentObject var favorite: AddedCities
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Switch UI Content")
                    .padding()

                Spacer()

                NavigationLink(
                    destination: SecondView(),
                    isActive: $isSecondViewPresented,
                    label: {
                        EmptyView()
                    });
                List(favorite.addedCities) { city in
                    NavigationLink(destination: CityView(viewModel: CityViewModel(), city: city)) {
                        Text(city.name)
                    }
                };

            

            }
            .navigationBarItems(leading: Button(action: {
                // Button action to present the SecondView
                isSecondViewPresented = true
            }, label: {
                Image(systemName: "arrow.left.circle")
                    .imageScale(.large)
            }))
            .navigationBarTitle("Météo", displayMode: .inline)
        }
    }
}

struct City: Identifiable,Decodable {
    let id: Int
    let name: String
    let latitude: Double
    let longitude: Double
    let elevation: Double
    let countryCode: String?
    let featureCode: String?
    let admin1Id: Int?
    let admin3Id: Int?
    let admin4Id: Int?
    let timezone: String
    let population: Int
    let postcodes: [String]
    let countryId: Int?
    let country: String
    let admin1: String?
    let admin3: String?
    let admin4: String?

    private enum CodingKeys: String, CodingKey {
        case id, name, latitude, longitude, elevation, countryCode,featureCode, admin1Id, admin3Id, admin4Id, timezone, population, postcodes, countryId, country, admin1, admin3, admin4
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        latitude = try container.decode(Double.self, forKey: .latitude)
        longitude = try container.decode(Double.self, forKey: .longitude)
        featureCode = try container.decodeIfPresent(String.self, forKey: .featureCode)
        elevation = try container.decode(Double.self, forKey: .elevation)
        countryCode = try container.decodeIfPresent(String.self, forKey: .countryCode)
        admin1Id = try container.decodeIfPresent(Int.self, forKey: .admin1Id)
        admin3Id = try container.decodeIfPresent(Int.self, forKey: .admin3Id)
        admin4Id = try container.decodeIfPresent(Int.self, forKey: .admin4Id)
        timezone = try container.decode(String.self, forKey: .timezone)
        population = try container.decode(Int.self, forKey: .population)
        postcodes = try container.decode([String].self, forKey: .postcodes)
        countryId = try container.decodeIfPresent(Int.self, forKey: .countryId)
        country = try container.decode(String.self, forKey: .country)
        admin1 = try container.decodeIfPresent(String.self, forKey: .admin1)
        admin3 = try container.decodeIfPresent(String.self, forKey: .admin3)
        admin4 = try container.decodeIfPresent(String.self, forKey: .admin4)
    }
}


struct SecondView: View {
    @State private var searchText: String = ""
    @State private var cities: [City] = []
    
    var body: some View {
        NavigationView {
            VStack {
                SearchBar(text: $searchText, onSearch: fetchCities)
                
                List(cities) { city in
                    NavigationLink(destination: CityView(viewModel: CityViewModel(), city: city)) {
                        Text(city.name)
                    }
                }
                .listStyle(PlainListStyle())
                .navigationTitle(Text("All Cities"))
            }
        }
        .onAppear {
            fetchCities()
        }
    }
    
    
    func fetchCities() {
        guard !searchText.isEmpty else {
            return
        }
        
        Task {
            do {
                cities = try await secondfetch(for: searchText)
            } catch {
                print("Error fetching cities: \(error)")
            }
        }
    }
    
    func secondfetch(for placeName: String) async throws -> [City] {
        guard let url = URL(string: "https://geocoding-api.open-meteo.com/v1/search?name=\(placeName)&count=2&language=fr&format=json") else {
            print("Invalid URL")
            throw ErrorPerso.invalidURL
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            
            // Decode the top-level JSON as a dictionary
            let topLevelJSON = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            
            // Extract the array of cities from the "results" key
            if let results = topLevelJSON?["results"] as? [[String: Any]] {
                // Convert the array of dictionaries to JSON data
                let jsonData = try JSONSerialization.data(withJSONObject: results, options: [])
                // Decode the array of City from the new JSON data
                let decodedCities = try JSONDecoder().decode([City].self, from: jsonData)
                return decodedCities
            } else {
                throw ErrorPerso.decodingFailed
            }
        } catch {
            print(error)
            throw error
        }
    }
}

    struct SearchBar: View {
        @Binding var text: String
        var onSearch: () -> Void

        var body: some View {
            HStack {
                /** refresh a chaque input
                 TextField("Search", text: $text)
                                 .textFieldStyle(RoundedBorderTextFieldStyle())
                                 .padding(.horizontal)
                                 .onChange(of: text) { _ in
                                     onSearch()
                                 }
                 */
                TextField("Search", text: $text, onCommit: {
                    onSearch()
                })
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

                Button(action: {
                    text = ""
                    onSearch()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                        .padding(.trailing, 8)
                }
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
