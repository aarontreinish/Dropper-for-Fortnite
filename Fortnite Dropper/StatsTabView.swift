//
//  StatsTabView.swift
//  Fortnite Dropper
//
//  Created by Aaron Treinish on 6/18/25.
//  Copyright © 2025 Aaron Treinish. All rights reserved.
//


import SwiftUI

struct StatsTabView: View {
    @State private var username: String = ""
    @State private var platform: String = "epic"
    @State private var stats: PlayerStats?
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.8)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Text("STATS")
                        .font(.fortnite(size: 48, weight: .heavy))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.8), radius: 4, x: 2, y: 2)
                        .padding(.top, 32)
                    
                    TextField("Epic Username", text: $username)
                        .padding()
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.white.opacity(0.4), lineWidth: 2)
                        )
                        .font(.fortnite(size: 22, weight: .regular))
                        .foregroundColor(.white)
                        .padding(.horizontal)

                    Picker("Platform", selection: $platform) {
                        Text("Epic").tag("epic")
                        Text("PSN").tag("psn")
                        Text("XBL").tag("xbl")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)

                    Button("Fetch Stats") {
                        fetchStats()
                    }
                    .font(.fortnite(size: 26, weight: .bold))
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)

                    if isLoading {
                        ProgressView()
                    } else if let stats = stats {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 16) {
                                StatGroupView(title: "Lifetime Stats", items: [
                                    "Score: \(stats.score)",
                                    "Score/Min: \(String(format: "%.2f", stats.scorePerMin))",
                                    "Score/Match: \(String(format: "%.2f", stats.scorePerMatch))",
                                    "Wins: \(stats.wins)",
                                    "Top 3: \(stats.top3 ?? 0)",
                                    "Top 5: \(stats.top5 ?? 0)"
                                ])

                                StatGroupView(title: nil, items: [
                                    "Top 6: \(stats.top6 ?? 0)",
                                    "Top 10: \(stats.top10 ?? 0)",
                                    "Top 12: \(stats.top12 ?? 0)",
                                    "Top 25: \(stats.top25 ?? 0)",
                                    "Kills: \(stats.kills)",
                                    "Kills/Min: \(String(format: "%.3f", stats.killsPerMin))"
                                ])

                                StatGroupView(title: nil, items: [
                                    "Kills/Match: \(String(format: "%.3f", stats.killsPerMatch))",
                                    "Deaths: \(stats.deaths)",
                                    "K/D: \(String(format: "%.3f", stats.kd))",
                                    "Matches: \(stats.matches)",
                                    "Win Rate: \(String(format: "%.3f", stats.winRate))%",
                                    "Minutes Played: \(stats.minutesPlayed)"
                                ])

                                StatGroupView(title: nil, items: [
                                    "Players Outlived: \(stats.playersOutlived)",
                                    "Last Modified: \(stats.lastModified)"
                                ])
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 12)
                        }
                    } else if let error = errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding()
                    }

                    Spacer()
                }
                .padding()
            }
        }
    }

    func fetchStats() {
        guard !username.isEmpty else { return }
        isLoading = true
        errorMessage = nil
        stats = nil

        let encodedUsername = username.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? username
        let urlString = "https://fortnite-api.com/v2/stats/br/v2?name=\(encodedUsername)&accountType=\(platform)"

        guard let url = URL(string: urlString) else {
            errorMessage = "Invalid URL"
            isLoading = false
            return
        }

        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("92c33d03-c1be-4fc5-b104-467fa7b5a416", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false

                if let error = error {
                    errorMessage = "Error: \(error.localizedDescription)"
                    return
                }

                guard let data = data else {
                    errorMessage = "No data received"
                    return
                }
                
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Raw JSON response:\n\(jsonString)")
                }

                do {
                    let decoded = try JSONDecoder().decode(FortniteStatsResponse.self, from: data)
                    stats = decoded.data?.stats.all.overall
                } catch {
                    print("Error decoding response: \(error)")
                    errorMessage = "Could not decode response"
                }
            }
        }.resume()
    }
}

private struct StatGroupView: View {
    let title: String?
    let items: [String]

    var body: some View {
        Group {
            if let title = title {
                Text(title)
                    .font(.fortnite(size: 30, weight: .bold))
                    .padding(.bottom, 4)
                Divider()
                    .background(Color.white.opacity(0.3))
            }
            VStack(alignment: .leading, spacing: 8) {
                ForEach(items, id: \.self) { stat in
                    Text(stat)
                        .font(.fortnite(size: 24, weight: .regular))
                        .padding(10)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(8)
                }
            }
        }
    }
}
