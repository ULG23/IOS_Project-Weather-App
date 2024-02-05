//
//  ContentView.swift
//  ProjetIOS
//
//  Created by justin sottile on 02/02/2024.
//

import SwiftUI

struct ContentView: View {
    @State private var isSecondViewPresented = false

    var body: some View {
        NavigationView {
            VStack {
                // Your Switch UI goes here
                Text("Switch UI Content")
                    .padding()

                Spacer()

                NavigationLink(
                    destination: SecondView(),
                    isActive: $isSecondViewPresented,
                    label: {
                        EmptyView()
                    })
            }
            .navigationBarItems(leading: Button(action: {
                // Button action to present the SecondView
                isSecondViewPresented = true
            }, label: {
                Image(systemName: "arrow.left.circle")
                    .imageScale(.large)
            }))
            .navigationBarTitle("Switch UI Example", displayMode: .inline)
        }
    }
}

/*struct BirdList: View {
@State var filterText: String = ""
var body: some View {
    NavigationView {
        List(BirdBase.shared.allBirds.filter({ filterText == "" ||
            $0.commonName.contains(filterText)})) { bird in
                NavigationLink(destination: Text(bird.commonName)) {
                    BirdRow(bird: bird)
                }
            }
        .listStyle(.plain)
        .navigationTitle(Text("Oiseaux"))
        }
        .searchable(text: $filterText)
        .onAppear {
         Task {
             await fetchBirds()
         }
        }
    }
}*/

struct Bird: Identifiable, Decodable {
    var id = UUID()
    var commonName: String
    var imagePath: String
}


struct SecondView: View {
    @State private var searchText: String = ""
    @State private var birds: [Bird] = []

    var body: some View {
        NavigationView {
            VStack {
                SearchBar(text: $searchText, onSearch: fetchBirds)
                
                List(birds) { bird in
                    HStack {
                        NavigationLink(destination: Text(bird.commonName)) {
                            Image(bird.imagePath)
                                .resizable()
                                .frame(width: 32, height: 32)
                            Text(bird.commonName)
                        }
                    }
                }
                .listStyle(PlainListStyle())
                .navigationTitle(Text("All ville"))
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: addBird) {
                            Text("Add")
                        }
                    }
                }
            }
        }
        .onAppear {
            // Fetch initial data when the view appears
            fetchBirds()
        }
    }

    func addBird() {
        // Implementation goes here
    }

    func fetchBirds() {
        guard !searchText.isEmpty else {
            // Handle the case where searchText is empty
            return
        }

        Task {
            do {
                birds = try await secondfetch(for: searchText)
            } catch {
                print(error)
            }
        }
    }

    func secondfetch(for placeName: String) async throws -> [Bird] {
        guard let url = URL(string: "https://geocoding-api.open-meteo.com/v1/search?name=\(placeName)&count=10&language=fr&format=json") else {
            print("Invalid URL")
            throw ErrorPerso.invalidURL
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decodedBirds = try JSONDecoder().decode([Bird].self, from: data)
            return decodedBirds
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
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
