//
//  SusbcribeView.swift
//  Fortnite Dropper
//
//  Created by Aaron Treinish on 12/11/22.
//  Copyright © 2022 Aaron Treinish. All rights reserved.
//

import SwiftUI
import RevenueCat

struct SusbcribeView: View {
//    @AppStorage("isSubscribed") private var isSubscribed = false
    @State var isSubscribed = false
    @State var products: [StoreProduct] = []
    @State var isInProgress = false
    
    var body: some View {
        if isInProgress {
            VStack {
                ProgressView()
            }
        } else if isSubscribed {
            VStack(spacing: 10) {
                Text("🎊 Congrats! 🎊")
                    .font(.largeTitle)
                    .multilineTextAlignment(.center)
                    .padding()
                Text("You have removed all ads from the app! Thank you for the support, enjoy!")
                    .font(.title3)
                    .multilineTextAlignment(.center)
                    .padding()
            }
            .padding()
            .onDisappear {
                let nc = NotificationCenter.default
                nc.post(name: Notification.Name("PeformAfterPresenting"), object: nil)
            }
        } else {
            VStack {
                Image("logo")
                    .resizable()
                    .frame(width: 150, height: 150)
                    .cornerRadius(20)
                    .padding(.top)
                
                Text("Remove Ads!")
                    .font(.title)
                
                HStack(spacing: 10) {
                    Image(systemName: "checkmark")
                        .resizable()
                        .frame(width: 20, height: 20)
                    
                    Text("This one time purchase will remove all ads from the app")
                }
                .padding()
                
                HStack(spacing: 10) {
                    Image(systemName: "checkmark")
                        .resizable()
                        .frame(width: 20, height: 20)
                    
                    Text("This includes both the banner ad and the pop up ad when choosing where to drop or what challenge to do")
                }
                .padding()
                
                HStack(spacing: 10) {
                    Image(systemName: "checkmark")
                        .resizable()
                        .frame(width: 20, height: 20)
                    
                    Text("You can now choose where to drop or what challenge to do as many times as you want without being interruped")
                }
                .padding()
                
                Spacer()
                
                if !products.isEmpty {
                    Button {
                        self.isInProgress = true
                        Purchases.shared.purchase(product: self.products[0]) { (transaction, customerInfo, error, userCancelled) in
                            guard let transaction = transaction , let customerInfo = customerInfo, error == nil, !userCancelled else {
                                self.isInProgress = false
                                return
                            }
                            print(transaction)
                            if customerInfo.entitlements[Constants.entitlementID]?.isActive == true {
                                print(customerInfo.entitlements)
                                self.isInProgress = false
                                self.isSubscribed = true
                            }
                        }
                    } label: {
                        Text("Remove Ads for \(self.products[0].localizedPriceString)")
                    }
                    .padding(.bottom)
                }
                
                Button {
                    self.isInProgress = true
                    Purchases.shared.restorePurchases { customerInfo, error in
                        //... check customerInfo to see if entitlement is now active
                        if let customerInfo = customerInfo {
                            if customerInfo.entitlements[Constants.entitlementID]?.isActive == true {
                              // user has access to "your_entitlement_id"
                                self.isInProgress = false
                                self.isSubscribed = true
                            } else {
                                self.isInProgress = false
                                self.isSubscribed = false
                            }
                        } else {
                            self.isInProgress = false
                            self.isSubscribed = false
                        }
                        
                        if let error = error {
                            print(error)
                            self.isInProgress = false
                            self.isSubscribed = false
                        }
                    }
                } label: {
                    Text("Restore purchases")
                }

            }
            .onDisappear {
                let nc = NotificationCenter.default
                nc.post(name: Notification.Name("PeformAfterPresenting"), object: nil)
            }
            .onAppear {
                Purchases.shared.getProducts(["\(Constants.productID)"]) { products in
                    self.products = products
                }
            }
        }
    }
}

struct SusbcribeView_Previews: PreviewProvider {
    static var previews: some View {
        SusbcribeView()
    }
}
