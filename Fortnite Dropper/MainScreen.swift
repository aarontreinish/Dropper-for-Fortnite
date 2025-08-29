//
//  MainScreen.swift
//  Fortnite Dropper
//
//  Created by Aaron Treinish on 6/18/25.
//  Copyright © 2025 Aaron Treinish. All rights reserved.
//

import SwiftUI
import Firebase
import RevenueCatUI
import RevenueCat
import KeychainSwift

struct MainScreen: View {
    @State private var dropResult: String?
    @State private var challengeResult: String?
    @State private var tapCountSnapshot: Int = 0
    @State private var showPaywall = false
    @State private var isLoading = false
    @Binding var fortniteLocations: [String]
    @State private var fortniteChallenges: [String] = []
    @State private var showConfetti = false

    @State private var showDropOverlay = false
    @State private var showChallengeOverlay = false
    @State private var showOverlayText: String?
    @State private var selectedMode: String = "Solo"
    @State private var dropSpinnerAngle: Double = 0
    @State private var challengeSpinnerAngle: Double = 0
    @State private var mapImageURL: String?
    @AppStorage("isFirstLaunch") var isFirstLaunch: Bool = true
    let keychain = KeychainSwift()
    let deviceIDKey = "com.dropper.deviceID"

    let tapLimit = 3
    @State private var isUserSubscribed = false

    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.8)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    Text("🎯 FORTNITE DROPPER")
                        .font(.fortnite(size: 36, weight: .heavy))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.8), radius: 4, x: 2, y: 2)
                        .padding(.top, 32)
                    
                    Picker("Mode", selection: $selectedMode) {
                        Text("Solo").tag("Solo")
                        Text("Duo").tag("Duo")
                        Text("Squad").tag("Squad")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(10)
                    .shadow(radius: 3)
                    .padding(.horizontal)
                    
                    // Roulette Wheel Buttons
                    RouletteWheelButton(label: "🎲 Drop", action: handleDropTap, spinnerAngle: $dropSpinnerAngle)
                        .disabled(isLoading)
                    RouletteWheelButton(label: "🔥 Challenge", action: handleChallengeTap, spinnerAngle: $challengeSpinnerAngle)
                        .disabled(isLoading)
                    
                    // Tap Tracker
                    if !isUserSubscribed {
                        VStack(spacing: 4) {
                            Text("TAPS TODAY")
                                .font(.fortnite(size: 12))
                                .foregroundColor(.white.opacity(0.8))
                            Text("\(tapCountSnapshot)/\(tapLimit)")
                                .font(.fortnite(size: 22, weight: .bold))
                                .foregroundColor(.green)
                            ProgressView(value: Float(tapCountSnapshot), total: Float(tapLimit))
                                .progressViewStyle(LinearProgressViewStyle(tint: .green))
                                .frame(width: 200)
                        }
                        .padding(.top, 12)
                        .background(Color.black.opacity(0.2))
                        .cornerRadius(12)
                        .padding(.horizontal)

                        Button(action: {
                            showPaywall = true
                        }) {
                            Text("Subscribe for Unlimited Drops and Challenges")
                                .font(.fortnite(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(Color.orange)
                                .cornerRadius(10)
                                .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                        }
                        .padding(.top, 8)
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .onAppear {
                fetchData()
                checkIfUserIsSusbcribed { isSubscribed in
                    isUserSubscribed = isSubscribed
                    tapCountSnapshot = getDailyTapCount()
                    
                    if isFirstLaunch {
                        if !isSubscribed {
                            showPaywall = true
                        }
                        
                        isFirstLaunch = false
                    }
                    
                }
            }
            .fullScreenCover(isPresented: $showPaywall) {
                PurchaseView(isPresented: $showPaywall)
            }
            .overlay(
                ZStack {
                    if showConfetti {
                        ForEach(0..<15) { _ in
                            Circle()
                                .fill(Color.random)
                                .frame(width: 8, height: 8)
                                .position(x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                                          y: CGFloat.random(in: 0...UIScreen.main.bounds.height))
                                .opacity(0.8)
                        }
                    }
                }
                    .animation(.easeOut(duration: 1), value: showConfetti)
            )
            .overlay(
                Group {
                    if let text = showOverlayText {
                        ResultOverlayCard(text: text) {
                            withAnimation {
                                showOverlayText = nil
                            }
                        }
                        .background(.ultraThinMaterial)
                        .transition(.asymmetric(
                            insertion: .scale(scale: 0.8).combined(with: .opacity),
                            removal: .opacity
                        ))
                        .animation(.spring(response: 0.5, dampingFraction: 0.7), value: showOverlayText)
                        .zIndex(1)
                    }
                }
            )
            .navigationViewStyle(StackNavigationViewStyle())
        }
    }

    // MARK: - Actions

    func getPersistentDeviceID() -> String {
        if let existing = keychain.get(deviceIDKey) {
            return existing
        } else {
            let newID = UUID().uuidString
            keychain.set(newID, forKey: deviceIDKey)
            return newID
        }
    }

    func namespacedKey(_ key: String) -> String {
        return "\(getPersistentDeviceID())_\(key)"
    }

    func getDailyTapCount() -> Int {
        let dateKey = namespacedKey("lastTapDate")
        let countKey = namespacedKey("dailyTapCount")

        let savedDateString = keychain.get(dateKey)
        let savedDate = savedDateString.flatMap { ISO8601DateFormatter().date(from: $0) } ?? Date.distantPast

        if !Calendar.current.isDateInToday(savedDate) {
            keychain.set(ISO8601DateFormatter().string(from: Date()), forKey: dateKey)
            keychain.set("0", forKey: countKey)
            return 0
        }

        return Int(keychain.get(countKey) ?? "0") ?? 0
    }

    func incrementDailyTapCount() {
        let countKey = namespacedKey("dailyTapCount")
        let dateKey = namespacedKey("lastTapDate")

        let current = getDailyTapCount()
        keychain.set(String(current + 1), forKey: countKey)
        keychain.set(ISO8601DateFormatter().string(from: Date()), forKey: dateKey)
    }

    func handleDropTap() {
        checkIfUserIsSusbcribed { isSubscribed in
            if isSubscribed {
                withAnimation(.easeInOut(duration: 1.2)) {
                    dropSpinnerAngle += 720
                }

                dropResult = fortniteLocations.shuffled().first
                showOverlayText = "Drop at: \(dropResult ?? "")"
                triggerConfetti()
            } else {
                guard getDailyTapCount() < tapLimit else {
                    showPaywall = true
                    return
                }

                incrementDailyTapCount()
                tapCountSnapshot = getDailyTapCount()

                withAnimation(.easeInOut(duration: 1.2)) {
                    dropSpinnerAngle += 720
                }

                dropResult = fortniteLocations.shuffled().first
                showOverlayText = "Drop at: \(dropResult ?? "")"
                triggerConfetti()
            }
        }
    }

    func handleChallengeTap() {
        checkIfUserIsSusbcribed { isSubscribed in
            if isSubscribed {
                withAnimation(.easeInOut(duration: 1.2)) {
                    challengeSpinnerAngle += 720
                }

                let filteredChallenges = fortniteChallenges.filter { challenge in
                    challenge.hasPrefix("\(selectedMode):") || !challenge.contains(":")
                }

                guard let challenge = filteredChallenges.shuffled().first else {
                    showOverlayText = "No challenges available."
                    return
                }

                challengeResult = challenge
                showOverlayText = challenge.components(separatedBy: ": ").last ?? challenge
                triggerConfetti()
            } else {
                guard getDailyTapCount() < tapLimit else {
                    showPaywall = true
                    return
                }

                incrementDailyTapCount()
                tapCountSnapshot = getDailyTapCount()

                withAnimation(.easeInOut(duration: 1.2)) {
                    challengeSpinnerAngle += 720
                }

                let filteredChallenges = fortniteChallenges.filter { challenge in
                    challenge.hasPrefix("\(selectedMode):") || !challenge.contains(":")
                }

                guard let challenge = filteredChallenges.shuffled().first else {
                    showOverlayText = "No challenges available."
                    return
                }

                challengeResult = challenge
                showOverlayText = challenge.components(separatedBy: ": ").last ?? challenge
                triggerConfetti()
            }
        }
    }

    func fetchData() {
        Task {
            do {
                let challengeDocs = try await Firestore.firestore().collection("challenges").getDocuments()
                fortniteChallenges = challengeDocs.documents.compactMap { $0["challenge"] as? String }
            } catch {
                print("Error fetching data: \(error)")
            }
        }
    }

    func tagAndWriteChallenges() {
        let rawChallenges = [
            // Solo
            "No Gun Challenge", "0 Kill Win Challenge", "Pistol Only Challenge", "No Reload Challenge",
            "One Gun Only Challenge", "Gray Guns Only Challenge", "Pickaxe Only Challenge", "Sniper Only Challenge",
            "SMG Only Challenge", "Shotgun Only Challenge", "Solo Stealth: Hide until final circle",
            "Solo Medic: Only carry healing items", "Solo Sprint: Never stop sprinting",

            // Duo
            "Duo: Share all loot evenly", "Duo: Stay within 10 meters of each other", "Duo: Only one teammate can build",
            "Duo: Only revive your teammate once", "Duo: One teammate uses weapons, one heals", "Duo: Communicate using only pings",

            // Squad
            "Squad: Each player lands at a different POI", "Squad: One person calls all decisions",
            "Squad: No comms, only emotes", "Squad: Protect the lowest health teammate",
            "Squad: Use only green weapons", "Squad: Rotate using vehicles only",

            // Universal
            "No Building Challenge", "Sky Base Challenge", "Pick up Enemy's Loadout Challenge",
            "Floor is Lava Challenge", "One Chest Only Challenge", "All Medalions Challenge",
            "No Meds Challenge", "Rainbow Gun Challenge", "Only use items from vending machines",
            "Must dance after every elimination", "Cannot open supply drops", "No aiming down sights"
        ]

        let db = Firestore.firestore()

        for raw in rawChallenges {
            let tag: String
            let lower = raw.lowercased()

            if lower.contains("solo") || lower.contains("0 kill") || lower.contains("no gun") {
                tag = "Solo"
            } else if lower.contains("duo") || lower.contains("partner") {
                tag = "Duo"
            } else if lower.contains("squad") || lower.contains("teammate") {
                tag = "Squad"
            } else if lower.contains("smg") || lower.contains("shotgun") || lower.contains("sniper") || lower.contains("pistol") || lower.contains("pickaxe") || lower.contains("loadout") || lower.contains("gray") {
                tag = "Solo"
            } else {
                tag = "" // universal
            }

            let finalChallenge = tag.isEmpty ? raw : "\(tag): \(raw)"
            let docID = UUID().uuidString
            db.collection("challenges").document(docID).setData([
                "challenge": finalChallenge
            ]) { error in
                if let error = error {
                    print("🔥 Error writing challenge: \(error)")
                } else {
                    print("✅ Wrote challenge: \(finalChallenge)")
                }
            }
        }
    }
    
    func checkIfUserIsSusbcribed(completion: @escaping (Bool) -> Void) {
        Purchases.shared.getCustomerInfo { (customerInfo, error) in
            if let customerInfo = customerInfo {
                if customerInfo.entitlements[Constants.subscription]?.isActive == true {
                  // user has access to "your_entitlement_id"
                    completion(true)
                } else {
                    completion(false)
                }
            } else {
                completion(false)
            }
            
            if let error = error {
                print(error)
                completion(false)
            }
        }
    }

    func triggerConfetti() {
//        showConfetti = true
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//            showConfetti = false
//        }
    }

    @ViewBuilder
    func animatedCard(text: String) -> some View {
        Text(text)
            .font(.fortnite(size: 22, weight: .bold))
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.black.opacity(0.85))
                    .shadow(radius: 10)
            )
            .padding(.horizontal, 24)
            .transition(.scale.combined(with: .opacity))
            .animation(.spring(response: 0.5, dampingFraction: 0.6), value: text)
    }
}

struct ResultOverlayCard: View {
    let text: String
    let onDismiss: () -> Void

    var body: some View {
        VStack {
            Spacer()
            VStack(spacing: 16) {
                Text(text)
                    .font(.fortnite(size: 28, weight: .bold))
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        LinearGradient(gradient: Gradient(colors: [.yellow, .orange]),
                                       startPoint: .top,
                                       endPoint: .bottom)
                    )
                    .cornerRadius(16)

                Button(action: onDismiss) {
                    Text("Dismiss")
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white.opacity(0.15))
                        )
                        .shadow(color: .white.opacity(0.2), radius: 3, x: 0, y: 3)
                }
            }
            .padding()
            .background(Color.purple.opacity(0.9))
            .cornerRadius(20)
            .padding()
            .shadow(radius: 20)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.4).ignoresSafeArea().onTapGesture {
            onDismiss()
        })
    }
}

extension Color {
    static var random: Color {
        return Color(hue: Double.random(in: 0...1),
                     saturation: 0.8,
                     brightness: 0.9)
    }
}

// MARK: - RouletteWheelButton
struct RouletteWheelButton: View {
    let label: String
    let action: () -> Void
    @Binding var spinnerAngle: Double

    var body: some View {
        Button(action: {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            withAnimation(.easeInOut(duration: 1.5)) {
                spinnerAngle += Double.random(in: 720...1440)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                action()
            }
        }) {
            ZStack {
                Circle()
                    .fill(AngularGradient(
                        gradient: Gradient(colors: [.purple, .blue, .cyan, .purple]),
                        center: .center))
                    .frame(width: 180, height: 180)
                    .rotationEffect(.degrees(spinnerAngle))

                Text(label)
                    .font(.fortnite(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.black.opacity(0.75))
                    .clipShape(Capsule())
            }
        }
    }
}

extension Font {
    static func fortnite(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        return .custom("Burbank Big Condensed Black", size: size).weight(weight)
    }
}
