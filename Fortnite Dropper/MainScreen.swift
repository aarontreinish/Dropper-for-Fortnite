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

struct MainScreen: View {
    @State private var dropResult: String?
    @State private var challengeResult: String?
    @State private var tapCountSnapshot: Int = 0
    @State private var showPaywall = false
    @State private var isLoading = false
    @State private var fortniteLocations: [String] = []
    @State private var fortniteChallenges: [String] = []
    @State private var showConfetti = false

    @State private var showDropOverlay = false
    @State private var showChallengeOverlay = false
    @State private var showOverlayText: String?

    let tapLimit = 100

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Text("🎯 Fortnite Dropper")
                    .font(.largeTitle.bold())
                    .foregroundColor(.yellow)
                    .shadow(color: .black.opacity(0.7), radius: 4, x: 2, y: 2)
                    .padding(.top, 32)

                // Drop Button
                Button(action: handleDropTap) {
                    Text("🎲 Drop Location")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(gradient: Gradient(colors: [.purple, .blue]),
                                           startPoint: .topLeading,
                                           endPoint: .bottomTrailing)
                        )
                        .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 5)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .disabled(isLoading)

                // Challenge Button
                Button(action: handleChallengeTap) {
                    Text("🔥 Challenge Me")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(gradient: Gradient(colors: [.purple, .blue]),
                                           startPoint: .topLeading,
                                           endPoint: .bottomTrailing)
                        )
                        .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 5)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .disabled(isLoading)

                // Tap Tracker
                VStack(spacing: 4) {
                    Text("Taps Today: \(tapCountSnapshot)/\(tapLimit)")
                    ProgressView(value: Float(tapCountSnapshot), total: Float(tapLimit))
                        .progressViewStyle(LinearProgressViewStyle(tint: .green))
                        .frame(width: 200)
                }
                .padding(.top, 12)

                Spacer()
            }
            .padding()
            .onAppear {
                fetchData()
                tapCountSnapshot = getDailyTapCount()
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView() // Use your actual paywall here
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
                        .transition(.scale.combined(with: .opacity))
                        .zIndex(1)
                    }
                }
            )
        }
    }

    // MARK: - Actions

    func getDailyTapCount() -> Int {
        let savedDate = UserDefaults.standard.object(forKey: "lastTapDate") as? Date ?? Date.distantPast
        if !Calendar.current.isDateInToday(savedDate) {
            UserDefaults.standard.set(Date(), forKey: "lastTapDate")
            UserDefaults.standard.set(0, forKey: "dailyTapCount")
            return 0
        }
        return UserDefaults.standard.integer(forKey: "dailyTapCount")
    }

    func incrementDailyTapCount() {
        let current = getDailyTapCount()
        UserDefaults.standard.set(current + 1, forKey: "dailyTapCount")
        UserDefaults.standard.set(Date(), forKey: "lastTapDate")
    }

    func handleDropTap() {
        guard getDailyTapCount() < tapLimit else {
            showPaywall = true
            return
        }

        incrementDailyTapCount()
        tapCountSnapshot = getDailyTapCount()
        dropResult = fortniteLocations.randomElement()
        showOverlayText = "Drop at: \(dropResult ?? "")"
        triggerConfetti()
    }

    func handleChallengeTap() {
        guard getDailyTapCount() < tapLimit else {
            showPaywall = true
            return
        }

        incrementDailyTapCount()
        tapCountSnapshot = getDailyTapCount()
        challengeResult = fortniteChallenges.randomElement()
        showOverlayText = "Challenge: \(challengeResult ?? "")"
        triggerConfetti()
    }

    func fetchData() {
        Task {
            do {
                let locationDocs = try await Firestore.firestore().collection("locations").getDocuments()
                fortniteLocations = locationDocs.documents.compactMap { $0["location"] as? String }

                let challengeDocs = try await Firestore.firestore().collection("challenges").getDocuments()
                fortniteChallenges = challengeDocs.documents.compactMap { $0["challenge"] as? String }
            } catch {
                print("Error fetching data: \(error)")
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
            .font(.title2.bold())
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
                    .font(.title.bold())
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
