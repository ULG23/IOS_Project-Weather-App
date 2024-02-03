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
    var birds: [Bird] = [
        Bird(commonName: "Mésange charbonnière", imagePath: "Parus major"),
        Bird(commonName: "Pinson des arbres", imagePath: "Fringilla coelebs"),
        Bird(commonName: "Merle noir", imagePath: "Turdus merula")
    ]

    var body: some View {
        NavigationView {
            List {
                ForEach(birds) { bird in
                    HStack {
                        NavigationLink(destination: Text(bird.commonName)) {
                            Image(bird.imagePath)
                                .resizable()
                                .frame(width: 32, height: 32)
                            Text(bird.commonName)
                        }
                    }}
            }
            .listStyle(PlainListStyle())
            .navigationTitle(
                Text("All ville"))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: addBird) {
                        Text("Add")
                    }
                }
            }
            List {
                Section(header: Text("Individus")) {
                    ForEach(birds) { bird in
                        HStack {
                            Image(systemName: bird.imagePath) // Use an SF Symbol or provide a valid image name
                                .resizable()
                                .frame(width: 32, height: 32)
                            Text(bird.commonName)
                        }
                    }
                }
            }
            .navigationBarTitle("Birds List", displayMode: .inline)
        }
    }
    func addBird() {
        // Implementation goes here
    }
        func fetch() async {
            let name = "YourPlaceName" // Replace with the actual place name

            guard let url = URL(string: "https://geocoding-api.open-meteo.com/v1/search?name=\(name)&count=10&language=fr&format=json") else {
                print("Invalid URL")
                return
            }
            
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                // Process the raw data result
                print(String(data: data, encoding: .utf8))
                // Handle the raw data as needed
                // ...
                
            } catch {
                print(error)
            }
        }
        func secondfetch() async throws -> [Bird] {
            let name = "YourPlaceName" // Replace with the actual place name
            enum YourError: Error {
                case invalidURL
            }
            guard let url = URL(string: "https://geocoding-api.open-meteo.com/v1/search?name=\(name)&count=10&language=fr&format=json") else {
                print("Invalid URL")
                throw YourError.invalidURL
            }

            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                // Process the raw data result
                print(String(data: data, encoding: .utf8))
                // Handle the raw data as needed
                // ...

                // Mocking data for testing, replace it with your actual parsing logic
               
                let decodedBirds = try JSONDecoder().decode([Bird].self, from: data)
                return decodedBirds
            } catch {
                print(error)
                throw error
            }
        }
}




struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
