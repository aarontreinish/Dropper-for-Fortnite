//
//  MapView.swift
//  Fortnite Dropper
//
//  Created by Aaron Treinish on 6/18/25.
//  Copyright © 2025 Aaron Treinish. All rights reserved.
//

import SwiftUI
import Zoomable

struct MapView: View {
    @Binding var mapImageURL: String
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color.purple, Color.blue]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                if let url = URL(string: mapImageURL) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .scaledToFit()
                            .padding()
                            .cornerRadius(16)
                            .shadow(radius: 10)
                            .zoomable()
                    } placeholder: {
                        ProgressView()
                    }
                } else {
                    Text("Map loading...")
                        .font(.fortnite(size: 20))
                        .foregroundColor(.white)
                }
            }
        }
    }
}
