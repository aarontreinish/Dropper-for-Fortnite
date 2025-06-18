//
//  FortniteDropperApp.swift
//  Fortnite Dropper
//
//  Created by Aaron Treinish on 6/18/25.
//  Copyright © 2025 Aaron Treinish. All rights reserved.
//

import SwiftUI
import Firebase
import RevenueCat

@main
struct FortniteDropperApp: App {
    init() {
        FirebaseApp.configure()
        
        Purchases.logLevel = .debug
        Purchases.configure(withAPIKey: Constants.apiKey)
    }

    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
    }
}
