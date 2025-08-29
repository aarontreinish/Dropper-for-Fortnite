//
//  PurchaseModel.swift
//  Fortnite Dropper
//
//  Created by Aaron Treinish on 8/29/25.
//  Copyright © 2025 Aaron Treinish. All rights reserved.
//


// PurchaseModel SwiftUI
// Created by Adam Lyttle on 7/18/2024

// Make cool stuff and share your build with me:

//  --> x.com/adamlyttleapps
//  --> github.com/adamlyttleapps

import Foundation
import StoreKit
import RevenueCat

class PurchaseModel: ObservableObject {
    
    @Published var productIds: [String]
    @Published var productDetails: [PurchaseProductDetails] = []

    @Published var isSubscribed: Bool = false
    @Published var isPurchasing: Bool = false
    @Published var isFetchingProducts: Bool = false
    
    init() {

        //initialise your productids and product details
        self.productIds = ["vic_roy_subscription_yearly", "vic_roy_subscription_weekly"]
        self.productDetails = [
            PurchaseProductDetails(price: "$25.99", productId: "vic_roy_subscription_yearly", duration: "year", durationPlanName: "Yearly Plan", hasTrial: false),
            PurchaseProductDetails(price: "$4.99", productId: "vic_roy_subscription_weekly", duration: "week", durationPlanName: "3-Day Trial", hasTrial: true)
        ]

    }
    
    func purchaseSubscription(productId: String) async {
        //trigger purchase process
        Purchases.shared.getProducts([productId]) { storeProducts in
            if let storeProduct = storeProducts.first {
                Task {
                    let result = try await Purchases.shared.purchase(product: storeProduct)
                    if result.customerInfo.entitlements[Constants.subscription]?.isActive == true {
                        DispatchQueue.main.async {
                            self.isSubscribed = true
                        }
                    }
                }
            }
        }
    }
    
    func restorePurchases() {
        //trigger restore purchases
        Purchases.shared.restorePurchases()
    }
    
}

class PurchaseProductDetails: ObservableObject, Identifiable {
    let id: UUID
    
    @Published var price: String
    @Published var productId: String
    @Published var duration: String
    @Published var durationPlanName: String
    @Published var hasTrial: Bool
    
    init(price: String = "", productId: String = "", duration: String = "", durationPlanName: String = "", hasTrial: Bool = false) {
        self.id = UUID()
        self.price = price
        self.productId = productId
        self.duration = duration
        self.durationPlanName = durationPlanName
        self.hasTrial = hasTrial
    }
    
}
