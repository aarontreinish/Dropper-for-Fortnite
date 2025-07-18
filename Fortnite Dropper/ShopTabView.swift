//
//  ShopTabView.swift
//  Fortnite Dropper
//
//  Created by Aaron Treinish on 6/18/25.
//  Copyright © 2025 Aaron Treinish. All rights reserved.
//

import SwiftUI
import SDWebImageSwiftUI
import RevenueCat
import RevenueCatUI

struct ShopTabView: View {
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var featuredEntries: [ShopEntry] = []
    @State private var dailyEntries: [ShopEntry] = []
    @State private var shopEntries: [ShopEntry] = []
    @State private var selectedTags: Set<String> = []

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
                    
                    ShopFilterBar(shopEntries: shopEntries, selectedTags: $selectedTags)
                    
                    Spacer()
                    
                    if isLoading {
                        ProgressView("Loading Shop...")
                    } else if let error = errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding()
                    } else {
                        ShopEntriesFilteredView(shopEntries: shopEntries, selectedTags: selectedTags)
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

struct ShopEntriesFilteredView: View {
    var shopEntries: [ShopEntry]
    var selectedTags: Set<String>

    var body: some View {
        let filtered = shopEntries.compactMap { entry -> ShopEntry? in
            guard let brItems = entry.brItems else { return nil }
            let filteredItems = selectedTags.isEmpty
                ? brItems
                : brItems.filter { item in
                    let tags = item.type.displayValue
                    return selectedTags.contains(tags)
                }
            guard !filteredItems.isEmpty else { return nil }

            return ShopEntry(
                regularPrice: entry.regularPrice,
                finalPrice: entry.finalPrice,
                devName: entry.devName,
                offerId: entry.offerId,
                inDate: entry.inDate,
                outDate: entry.outDate,
                giftable: entry.giftable,
                refundable: entry.refundable,
                sortPriority: entry.sortPriority,
                tileSize: entry.tileSize,
                layoutId: entry.layoutId,
                layout: entry.layout,
                section: entry.section,
                displayGroup: entry.displayGroup,
                newDisplayAsset: entry.newDisplayAsset,
                brItems: filteredItems
            )
        }

        return FortniteShopView(entries: filtered)
    }
}

struct ShopFilterBar: View {
    let shopEntries: [ShopEntry]
    @Binding var selectedTags: Set<String>
    @State var showPaywall = false
    @State private var isSubscribed = false

    var body: some View {
        HStack {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    let allTags = Array(Set(shopEntries.flatMap { $0.brItems?.map { $0.type.displayValue } ?? [] })).sorted()
                    ForEach(allTags, id: \.self) { tag in
                        Button(action: {
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()

                            checkIfUserIsSusbcribed { isSubscribed in
                                if isSubscribed {
                                    if selectedTags.contains(tag) {
                                        selectedTags.remove(tag)
                                    } else {
                                        selectedTags.insert(tag)
                                    }
                                } else {
                                    showPaywall = true
                                }
                            }
                        }) {
                            HStack {
                                Text(tag)
                                    .font(.fortnite(size: 24, weight: .heavy))
                                if !isSubscribed {
                                    Image(systemName: "lock.fill")
                                        .foregroundColor(.white)
                                }
                            }
                            .padding(8)
                            .background(selectedTags.contains(tag) ? Color.yellow : Color.gray.opacity(0.5))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                        }
                    }
                }.padding(.horizontal)
            }
        }
        .onAppear {
            checkIfUserIsSusbcribed { _ in }
        }
        .fullScreenCover(isPresented: $showPaywall) {
            PaywallView()
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    func checkIfUserIsSusbcribed(completion: @escaping (Bool) -> Void) {
        Purchases.shared.getCustomerInfo { (customerInfo, error) in
            if let customerInfo = customerInfo {
                let subscribed = customerInfo.entitlements[Constants.entitlementID]?.isActive == true || customerInfo.entitlements[Constants.subscription]?.isActive == true
                isSubscribed = subscribed
                completion(subscribed)
            } else {
                isSubscribed = false
                completion(false)
            }

            if let error = error {
                print(error)
                isSubscribed = false
                completion(false)
            }
        }
    }
}
