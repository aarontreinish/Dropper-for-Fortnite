//
//  ViewController.swift
//  Fortnite Dropper
//
//  Created by Aaron Treinish on 7/17/18.
//  Copyright © 2018 Aaron Treinish. All rights reserved.
//

import UIKit
import AVFoundation
import RevenueCat
import SwiftUI
import Firebase
import FirebaseFirestore
import RevenueCatUI

class ViewController: UIViewController {
    
    @IBOutlet var locationView: UIView!
    @IBOutlet var challengeView: UIView!
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var challengeLabel: UILabel!
    @IBOutlet weak var dropLocation: UIButton!
    @IBOutlet weak var whatChallenge: UIButton!
    
    var fortniteLocations: [String] = []
    
    var fortniteChallenges: [String] = []
    
    var effect: UIVisualEffect!
    
    var isDarkMode: Bool {
        if #available(iOS 13.0, *) {
            return self.traitCollection.userInterfaceStyle == .dark
        }
        else {
            return false
        }
    }
    
    var dailyTapCount: Int {
        get {
            let savedDate = UserDefaults.standard.object(forKey: "lastTapDate") as? Date ?? Date.distantPast
            if !Calendar.current.isDateInToday(savedDate) {
                UserDefaults.standard.set(Date(), forKey: "lastTapDate")
                UserDefaults.standard.set(0, forKey: "dailyTapCount")
                return 0
            }
            return UserDefaults.standard.integer(forKey: "dailyTapCount")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "dailyTapCount")
            UserDefaults.standard.set(Date(), forKey: "lastTapDate")
        }
    }
    
//    var audioPlayer = AVAudioPlayer()
//    var numberOfTaps = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        getLocations()
        getChallenges()
        
        effect = visualEffectView.effect
        visualEffectView.effect = nil
        
        locationView.layer.cornerRadius = 10
        challengeView.layer.cornerRadius = 10
        
        
        if isDarkMode {
            locationLabel.textColor = .black
            challengeLabel.textColor = .black
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(modalDidDismiss), name: NSNotification.Name(rawValue: "PeformAfterPresenting"), object: nil)
        
//        do {
//            audioPlayer = try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: "Hang Glider Sound", ofType: "mp3")!))
//            audioPlayer.prepareToPlay()
//        }
//        catch {
//            print(error)
//        }
        
    }
    
    func getLocations() {
        Firestore.firestore().collection("locations").getDocuments { snapshot, error in
            if let error {
                print(error)
            }
            
            if let snapshot {
                for document in snapshot.documents {
                    guard let location = document["location"] as? String else { return }
                    self.fortniteLocations.append(location)
                }
            }
        }
    }
    
    func getChallenges() {
        Firestore.firestore().collection("challenges").getDocuments { snapshot, error in
            if let error {
                print(error)
            }
            
            if let snapshot {
                for document in snapshot.documents {
                    guard let location = document["challenge"] as? String else { return }
                    self.fortniteChallenges.append(location)
                }
            }
        }
    }
    
    @objc func modalDidDismiss() {
        checkIfUserIsSusbcribed { isSubscribed in
//            if isSubscribed {
//                self.bannerView.isHidden = true
//                self.removeAdsButton.isHidden = true
//            } else {
//                self.bannerView.adUnitID = "ca-app-pub-7930281625187952/3947297105"
//                self.bannerView.rootViewController = self
//                self.bannerView.load(Request())
//                self.bannerView.delegate = self
//
////                self.interstitial = self.createAndLoadInterstitial()
//            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        checkIfUserIsSusbcribed { isSubscribed in
//            if isSubscribed {
//                self.bannerView.isHidden = true
//                self.removeAdsButton.isHidden = true
//            } else {
//                self.bannerView.adUnitID = "ca-app-pub-7930281625187952/3947297105"
//                self.bannerView.rootViewController = self
//                self.bannerView.load(Request())
//                self.bannerView.delegate = self
//
////                self.interstitial = self.createAndLoadInterstitial()
//            }
        }
    }
    
    func animateIn() {
        self.view.addSubview(locationView)
        locationView.center = self.view.center
        
        locationView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
        locationView.alpha = 0
        
//        audioPlayer.play()
        
        UIView.animate(withDuration: 0.4) {
            self.visualEffectView.effect = self.effect
            self.locationView.alpha = 1
            self.locationView.transform = CGAffineTransform.identity
        }
        
        whatChallenge.isEnabled = false
        dropLocation.isEnabled = false
    }
    
    
    
    
    func animateOut() {
        UIView.animate(withDuration: 0.3, animations: {
            self.locationView.transform = CGAffineTransform.init(scaleX: 1.3, y:1.3)
            self.locationView.alpha = 0
            
            self.visualEffectView.effect = nil
            
            
            
        }) { (successBool) in
            self.locationView.removeFromSuperview()
        }
//        audioPlayer.stop()
//        audioPlayer.currentTime = 0
        
        whatChallenge.isEnabled = true
        dropLocation.isEnabled = true
        
    }
    
    func animateInChallenge() {
        self.view.addSubview(challengeView)
        challengeView.center = self.view.center
        
        challengeView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
        challengeView.alpha = 0
        
//        audioPlayer.play()
        
        UIView.animate(withDuration: 0.4) {
            self.visualEffectView.effect = self.effect
            self.challengeView.alpha = 1
            self.challengeView.transform = CGAffineTransform.identity
        }
        
        dropLocation.isEnabled = false
        whatChallenge.isEnabled = false
    }
    
    func animateOutChallenge() {
        UIView.animate(withDuration: 0.3, animations: {
            self.challengeView.transform = CGAffineTransform.init(scaleX: 1.3, y:1.3)
            self.challengeView.alpha = 0
            
            self.visualEffectView.effect = nil
            
        }) { (successBool) in
            self.challengeView.removeFromSuperview()
        }
        
//        audioPlayer.stop()
//        audioPlayer.currentTime = 0
        
        dropLocation.isEnabled = true
        whatChallenge.isEnabled = true
        
    }
    
    
    @IBAction func dropLocation(_ sender: UIButton) {
        checkIfUserIsSusbcribed { isSubscribed in
            if !isSubscribed && self.dailyTapCount >= 5 {
                let vc = UIHostingController(rootView: PaywallView())
                self.present(vc, animated: true)
                return
            }
            self.dailyTapCount += 1
            
            DispatchQueue.main.async {
                self.animateIn()
                let locations = self.fortniteLocations
                let index = Int(arc4random_uniform(UInt32(locations.count)))
                self.locationLabel.text = locations[index]
            }
        }
        
//        numberOfTaps += 1
//        print(numberOfTaps)
    }
    
    @IBAction func dismissPopUp(_ sender: Any) {
        animateOut()
    }
    
    @IBAction func whatChallenge(_ sender: UIButton) {
        checkIfUserIsSusbcribed { isSubscribed in
            if !isSubscribed && self.dailyTapCount >= 5 {
                let vc = UIHostingController(rootView: PaywallView())
                self.present(vc, animated: true)
                return
            }
            self.dailyTapCount += 1
            
            DispatchQueue.main.async {
                self.animateInChallenge()
                let challenges = self.fortniteChallenges
                let index = Int(arc4random_uniform(UInt32(challenges.count)))
                self.challengeLabel.text = challenges[index]
            }
        }
        
//        numberOfTaps += 1
//        print(numberOfTaps)
        
    }
    
    @IBAction func dismissPopUpChallenge(_ sender: Any) {
        animateOutChallenge()
        
    }
    
    func checkIfUserIsSusbcribed(completion: @escaping (Bool) -> Void) {
        Purchases.shared.getCustomerInfo { (customerInfo, error) in
            if let customerInfo = customerInfo {
                if customerInfo.entitlements[Constants.entitlementID]?.isActive == true || customerInfo.entitlements[Constants.subscription]?.isActive == true {
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
}
