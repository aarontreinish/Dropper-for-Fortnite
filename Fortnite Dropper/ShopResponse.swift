//
//  ShopResponse.swift
//  Fortnite Dropper
//
//  Created by Aaron Treinish on 6/18/25.
//  Copyright © 2025 Aaron Treinish. All rights reserved.
//

import Foundation
import SwiftUI

struct FortniteShopResponse: Codable {
    let data: ShopData
}

struct ShopData: Codable {
    let entries: [ShopEntry]
}

struct ShopEntry: Codable {
    let regularPrice: Int?
    let finalPrice: Int?
    let devName: String?
    let offerId: String?
    let inDate: String?
    let outDate: String?
    let giftable: Bool?
    let refundable: Bool?
    let sortPriority: Int?
    let tileSize: String?
    let layoutId: String?
    let layout: ShopLayout?
    let section: ShopSection?
    let displayGroup: String?
    let newDisplayAsset: DisplayAsset?
    let brItems: [ShopItem]?
}

struct ShopLayout: Codable {
    let id: String?
    let name: String?
    let category: String?
    let index: Int?
    let rank: Int?
    let showIneligibleOffers: String?
    let background: String?
    let useWidePreview: Bool?
    let displayType: String?
    let textureMetadata: [MetadataEntry]?
    let stringMetadata: [MetadataEntry]?
    let textMetadata: [MetadataEntry]?
}

struct MetadataEntry: Codable {
    let key: String?
    let value: String?
}

struct ShopSection: Codable {
    let id: String?
    let name: String?
}

struct DisplayAsset: Codable {
    let id: String?
    let renderImages: [RenderImage]?
}

struct RenderImage: Codable {
    let productTag: String?
    let fileName: String?
    let image: String?
}

struct ShopItem: Codable, Hashable {
    let id: String
    let name: String
    let description: String
    let type: ItemType
    let rarity: ItemRarity
    let images: ItemImages
}

struct ItemType: Codable, Hashable {
    let value: String
    let displayValue: String
}

struct ItemRarity: Codable, Hashable {
    let value: String
    let displayValue: String
}

struct ItemImages: Codable, Hashable {
    let smallIcon: String?
    let icon: String?
    let featured: String?
}

