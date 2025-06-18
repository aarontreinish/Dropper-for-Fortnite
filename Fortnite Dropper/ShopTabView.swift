//
//  ShopTabView.swift
//  Fortnite Dropper
//
//  Created by Aaron Treinish on 6/18/25.
//  Copyright © 2025 Aaron Treinish. All rights reserved.
//

import SwiftUI
import SDWebImageSwiftUI

struct ShopTabView: View {
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var featuredEntries: [ShopEntry] = []
    @State private var dailyEntries: [ShopEntry] = []
    @State private var shopEntries: [ShopEntry] = []

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
                    Text("ITEM SHOP")
                        .font(.fortnite(size: 36, weight: .heavy))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.8), radius: 4, x: 2, y: 2)
                        .padding(.top, 32)
                    
                    Spacer()
                    
                    if isLoading {
                        ProgressView("Loading Shop...")
                    } else if let error = errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding()
                    } else {
                        FortniteShopView(entries: shopEntries)
                    }
                    
                    Spacer()
                }
            }
            .task {
                loadShop()
            }
        }
    }

    func loadShop() {
        isLoading = true
        errorMessage = nil
        Task {
            do {
                let url = URL(string: "https://fortnite-api.com/v2/shop")!
                var req = URLRequest(url: url)
                req.setValue("application/json", forHTTPHeaderField: "Accept")
                req.setValue("92c33d03-c1be-4fc5-b104-467fa7b5a416", forHTTPHeaderField: "Authorization")
                let (data, _) = try await URLSession.shared.data(for: req)

                let decoded = try JSONDecoder().decode(FortniteShopResponse.self, from: data)
                
                shopEntries = decoded.data.entries
                
                isLoading = false
            } catch {
                print("Error loading shop: \(error)")
                errorMessage = "Failed to load shop: \(error.localizedDescription)"
                isLoading = false
            }
        }
    }

    func findPrice(for itemId: String) -> Int? {
        for entry in featuredEntries + dailyEntries {
            if let brItems = entry.brItems, brItems.contains(where: { $0.id == itemId }) {
                return entry.finalPrice
            }
        }
        return nil
    }

}
