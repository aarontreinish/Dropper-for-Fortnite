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
                    gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.8)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack {
                    Text("Map")
                        .font(.fortnite(size: 36, weight: .heavy))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.8), radius: 4, x: 2, y: 2)
                        .padding(.top, 32)
                    
                    Spacer()
                    
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
                    
                    Spacer()
                }

            }
        }
    }
}

