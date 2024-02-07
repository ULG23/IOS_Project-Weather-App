//
//  SearchBar.swift
//  ProjetIOS
//
//  Created by Justin SOTTILE & Gauthier MIGUET on 07/02/2024.
//

import Foundation
import SwiftUI

struct SearchBar: View {
    @Binding var text: String
    var onSearch: () -> Void

    var body: some View {
        HStack {
            // refresh a chaque input
             TextField("Search", text: $text)
                             .textFieldStyle(RoundedBorderTextFieldStyle())
                             .padding(.horizontal)
                             .onChange(of: text) { _ in
                                 onSearch()
                             }
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
