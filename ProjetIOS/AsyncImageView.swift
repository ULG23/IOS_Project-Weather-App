//
//  AsyncImageView.swift
//  ProjetIOS
//
//  Created by Justin SOTTILE & Gauthier MIGUET on 07/02/2024.
//

import Foundation
import SwiftUI

struct AsyncImageView: View {
    var url: URL?
    
    var body: some View {
        AsyncImage(url: url) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: UIScreen.main.bounds.width)
        } placeholder: {
            ProgressView()
        }
    }
}
