//
//  FortniteStatsResponse.swift
//  Fortnite Dropper
//
//  Created by Aaron Treinish on 6/18/25.
//  Copyright © 2025 Aaron Treinish. All rights reserved.
//

import Foundation

struct FortniteStatsResponse: Codable {
    let status: Int
    let data: FortniteStatsData?
}

struct FortniteStatsData: Codable {
    let account: AccountInfo
    let battlePass: BattlePass
    let stats: FortniteStats
}

struct AccountInfo: Codable {
    let id: String
    let name: String
}

struct BattlePass: Codable {
    let level: Int
    let progress: Int
}

struct FortniteStats: Codable {
    let all: FortniteGameModes
    let keyboardMouse: FortniteGameModes?
    let gamepad: FortniteGameModes?
}

struct FortniteGameModes: Codable {
    let overall: PlayerStats
    let solo: PlayerStats
    let duo: PlayerStats
    let squad: PlayerStats
    let ltm: PlayerStats?
}

struct PlayerStats: Codable {
    let score: Int
    let scorePerMin: Double
    let scorePerMatch: Double
    let wins: Int
    let top3: Int?
    let top5: Int?
    let top6: Int?
    let top10: Int?
    let top12: Int?
    let top25: Int?
    let kills: Int
    let killsPerMin: Double
    let killsPerMatch: Double
    let deaths: Int
    let kd: Double
    let matches: Int
    let winRate: Double
    let minutesPlayed: Int
    let playersOutlived: Int
    let lastModified: String
}
