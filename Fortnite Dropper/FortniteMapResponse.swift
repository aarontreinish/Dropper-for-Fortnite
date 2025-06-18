//
//  FortniteMapResponse.swift
//  Fortnite Dropper
//
//  Created by Aaron Treinish on 6/18/25.
//  Copyright © 2025 Aaron Treinish. All rights reserved.
//

import Foundation

struct FortniteMapResponse: Codable {
    let data: FortniteMapData
}

struct FortniteMapData: Codable {
    let pois: [FortnitePOI]
    let images: FortniteMapImages
}

struct FortniteMapImages: Codable {
    let blank: String
    let pois: String
}

struct FortnitePOI: Codable {
    let name: String
}
