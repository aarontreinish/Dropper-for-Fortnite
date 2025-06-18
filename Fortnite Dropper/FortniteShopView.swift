//
//  FortniteShopView.swift
//  Fortnite Dropper
//
//  Created by Aaron Treinish on 6/18/25.
//  Copyright © 2025 Aaron Treinish. All rights reserved.
//

import SwiftUI
import SDWebImageSwiftUI

struct FortniteShopView: View {
    let entries: [ShopEntry]

    // Group entries by layout name
    private var groupedEntries: [(key: String, value: [ShopEntry])] {
        let groups = Dictionary(grouping: entries) { $0.layout?.name ?? "Other" }
        return groups
            .map { ($0.key, $0.value.sorted(by: { ($0.sortPriority ?? 0) < ($1.sortPriority ?? 0) })) }
            .sorted(by: { $0.0 < $1.0 }) // Sort by layout name
    }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 16) {
                ForEach(groupedEntries, id: \.key) { section in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(section.key)
                            .font(.fortnite(size: 24, weight: .bold))
                            .padding(.horizontal)
                        
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 120), spacing: 12)], spacing: 12) {
                            ForEach(section.value, id: \.offerId) { entry in
                                if let item = entry.brItems?.first {
                                    VStack(spacing: 6) {
                                        WebImage(url: URL(string: entry.newDisplayAsset?.renderImages?.first?.image ?? item.images.icon ?? ""))
                                            .resizable()
                                            .scaledToFit()
                                            .cornerRadius(8)
                                            .frame(height: 100)

                                        Text(item.name)
                                            .font(.fortnite(size: 18, weight: .bold))
                                            .lineLimit(2)
                                            .multilineTextAlignment(.center)

                                        let rarity = item.rarity.displayValue
                                        Text(rarity.uppercased())
                                            .font(.fortnite(size: 12, weight: .semibold))
                                            .foregroundColor(Color(rarityColor(rarity)))

                                        if let price = entry.finalPrice {
                                            Text("\(price) V-Bucks")
                                                .font(.fortnite(size: 14, weight: .medium))
                                                .foregroundColor(.yellow)
                                        }
                                    }
                                    .padding()
                                    .background(Color.black.opacity(0.25))
                                    .cornerRadius(10)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .padding(.top)
        }
    }
    
    func rarityColor(_ rarity: String) -> UIColor {
        switch rarity.lowercased() {
        case "legendary": return .orange
        case "epic": return .purple
        case "rare": return .blue
        case "uncommon": return .green
        case "common": return .gray
        default: return .white
        }
    }
}
