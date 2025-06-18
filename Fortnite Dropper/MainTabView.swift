//
//  MainTabView.swift
//  Fortnite Dropper
//
//  Created by Aaron Treinish on 6/18/25.
//  Copyright © 2025 Aaron Treinish. All rights reserved.
//

import SwiftUI

struct MainTabView: View {
    @State var locations: [String] = []
    @State var mapImageURL: String = ""
    var body: some View {
        TabView {
            MainScreen(fortniteLocations: $locations)
                .tabItem {
                    Label("Dropper", systemImage: "target")
                }
            
            MapView(mapImageURL: $mapImageURL)
                .tabItem {
                    Label("Map", systemImage: "map")
                }
        }
        .task {
            await fetchMapLocations()
        }
    }
    
    func fetchMapLocations() async {
        guard let url = URL(string: "https://fortnite-api.com/v1/map") else { return }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoded = try JSONDecoder().decode(FortniteMapResponse.self, from: data)
            let names = decoded.data.pois.map { $0.name }
            DispatchQueue.main.async {
                self.locations = names
                self.mapImageURL = decoded.data.images.pois
            }
        } catch {
            print("Error fetching map locations: \(error)")
        }
    }
}
