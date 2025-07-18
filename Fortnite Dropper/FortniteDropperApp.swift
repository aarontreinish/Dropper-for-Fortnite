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
import SDWebImageSwiftUI

@main
struct FortniteDropperApp: App {
    @AppStorage("hasFinishedOnboarding") var hasFinishedOnboarding: Bool = false
    
    init() {
        FirebaseApp.configure()
        
        Purchases.logLevel = .debug
        Purchases.configure(withAPIKey: Constants.apiKey)
    }

    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}

struct RootView: View {
    @AppStorage("hasFinishedOnboarding") var hasFinishedOnboarding: Bool = false

    var body: some View {
        Group {
            if hasFinishedOnboarding {
                MainTabView()
            } else {
                OnboardingView()
            }
        }
        .environment(\.colorScheme, .dark)
    }
}

struct OnboardingView: View {
    @AppStorage("hasFinishedOnboarding") var hasFinishedOnboarding: Bool = false
    @State private var currentPage = 0

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.8)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack {
                TabView(selection: $currentPage) {
                    VStack {
                        Text("🎯 Drop Smarter, Win More")
                            .font(.fortnite(size: 40, weight: .bold))
                            .bold()
                            .padding()
                            .multilineTextAlignment(.center)
                        
                        AnimatedImage(name: "drop_location.gif")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 350)
                        
                        Text("Take the guesswork out of landing – get strategic drop spots to improve your game.")
                            .font(.fortnite(size: 22, weight: .regular))
                            .multilineTextAlignment(.center)
                            .padding()
                    }
                    .tag(0)

                    VStack {
                        Text("🛍️ Never Miss a Must-Have")
                            .font(.fortnite(size: 40, weight: .bold))
                            .bold()
                            .padding()
                            .multilineTextAlignment(.center)
                        
                        AnimatedImage(name: "shop.gif")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 350)
                        
                        Text("Always know what’s in the shop so you can grab your favorite items before they’re gone.")
                            .font(.fortnite(size: 22, weight: .regular))
                            .multilineTextAlignment(.center)
                            .padding()
                    }
                    .tag(1)

                    VStack {
                        Text("📊 Get Better with Every Match")
                            .font(.fortnite(size: 40, weight: .bold))
                            .bold()
                            .padding()
                            .multilineTextAlignment(.center)
                        
                        AnimatedImage(name: "stats.gif")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 350)
                        
                        Text("Track your stats, discover trends, and level up your performance.")
                            .font(.fortnite(size: 22, weight: .regular))
                            .multilineTextAlignment(.center)
                            .padding()
                    }
                    .tag(2)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
                
                Spacer()
                
                PageControl(numberOfPages: 3, currentPage: $currentPage)
                
                Button(action: {
                    if currentPage < 2 {
                        currentPage += 1
                    } else {
                        withAnimation {
                            print("Onboarding complete")
                            hasFinishedOnboarding = true
                        }
                    }
                }) {
                    Text(currentPage == 2 ? "Get Started" : "Next")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
                .padding(.bottom)
            }
        }
    }
}

// MARK: - PageControl UIViewRepresentable
import UIKit

struct PageControl: UIViewRepresentable {
    var numberOfPages: Int
    @Binding var currentPage: Int

    func makeUIView(context: Context) -> UIPageControl {
        let control = UIPageControl()
        control.numberOfPages = numberOfPages
        control.currentPage = currentPage
        control.pageIndicatorTintColor = UIColor.systemGray4
        control.currentPageIndicatorTintColor = UIColor.systemBlue
        return control
    }

    func updateUIView(_ uiView: UIPageControl, context: Context) {
        uiView.currentPage = currentPage
    }
}
