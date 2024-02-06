//
//  ProjetIOSApp.swift
//  ProjetIOS
//
//  Created by justin sottile on 02/02/2024.
//

import SwiftUI


class AddedCities: ObservableObject {
    @Published var addedCities: [City] = []
}

@main
struct ProjetIOSApp: App {
    let addedCities = AddedCities()
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(addedCities)
        }
    }
}



