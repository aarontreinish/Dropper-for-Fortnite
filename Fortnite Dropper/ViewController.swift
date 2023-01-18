//
//  ViewController.swift
//  Fortnite Dropper
//
//  Created by Aaron Treinish on 7/17/18.
//  Copyright © 2018 Aaron Treinish. All rights reserved.
//

import UIKit
import GoogleMobileAds
import AVFoundation
import RevenueCat
import SwiftUI

class ViewController: UIViewController, GADBannerViewDelegate, GADInterstitialDelegate {
    
    @IBOutlet weak var bannerView: GADBannerView!
    @IBOutlet var locationView: UIView!
    @IBOutlet var challengeView: UIView!
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var challengeLabel: UILabel!
    @IBOutlet weak var dropLocation: UIButton!
    @IBOutlet weak var whatChallenge: UIButton!
    @IBOutlet weak var removeAdsButton: UIButton!
    
    var fortniteLocations = ["The Citadel", "Anvil Square", "Shattered Slabs", "Frenzy Fields", "Breakwater Bay", "Slappy Shores", "Faulty Splits", "Lonely Labs", "Brutal Bastion", "Take the battle bus to the end", "Drop immediately"]
    
    var fortniteChallenges = ["Mythic Weapon Only Challenge", "0 Kill Win Challenge", "No Meds Challenge", "One Gun Only Challenge", "Sniper Only Challenge", "Pistol Only Challenge", "One Chest Only Challenge", "No Reload Challenge", "No Gun Challenge", "No Building Challenge", "SMG Only Challenge", "Floor is Lava Challenge", "Rainbow Gun Challenge", "Pickaxe Only Challenge", "Shotgun Only Challenge", "Gray Guns Only Challenge", "Pick up Enemy's Loadout Challenge", "Cars Only Challenge", "Sky Base Challenge"]
    
    var effect: UIVisualEffect!
    
    var isDarkMode: Bool {
        if #available(iOS 13.0, *) {
            return self.traitCollection.userInterfaceStyle == .dark
        }
        else {
            return false
        }
    }
    
    
//    var audioPlayer = AVAudioPlayer()
    var interstitial: GADInterstitial!
    var numberOfTaps = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
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
    
    @objc func modalDidDismiss() {
        checkIfUserIsSusbcribed { isSubscribed in
            if isSubscribed {
                self.bannerView.isHidden = true
                self.removeAdsButton.isHidden = true
            } else {
                self.bannerView.adUnitID = "ca-app-pub-7930281625187952/3947297105"
                self.bannerView.rootViewController = self
                self.bannerView.load(GADRequest())
                self.bannerView.delegate = self
                
                self.interstitial = self.createAndLoadInterstitial()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        checkIfUserIsSusbcribed { isSubscribed in
            if isSubscribed {
                self.bannerView.isHidden = true
                self.removeAdsButton.isHidden = true
            } else {
                self.bannerView.adUnitID = "ca-app-pub-7930281625187952/3947297105"
                self.bannerView.rootViewController = self
                self.bannerView.load(GADRequest())
                self.bannerView.delegate = self
                
                self.interstitial = self.createAndLoadInterstitial()
            }
        }
    }
    
    func createAndLoadInterstitial() -> GADInterstitial {
        let interstitial = GADInterstitial(adUnitID: "ca-app-pub-7930281625187952/8747006959")
        interstitial.delegate = self
        interstitial.load(GADRequest())
        return interstitial
    }
    
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        interstitial = createAndLoadInterstitial()
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
        animateIn()
        let locations = fortniteLocations
        
        let index = Int(arc4random_uniform(UInt32(locations.count)))
        
        locationLabel.text = locations[index]
        
        numberOfTaps += 1
        print(numberOfTaps)
        
        checkIfUserIsSusbcribed(completion: { isSusbcribed in
            if !isSusbcribed {
                if self.numberOfTaps >= 2 {
                    if self.interstitial.isReady {
                        self.interstitial.present(fromRootViewController: self)
                        self.numberOfTaps = 0
                    } else {
                        print("Ad wasn't ready")
                        self.numberOfTaps = 0
                    }
                }
            }
        })
    }
    
    @IBAction func dismissPopUp(_ sender: Any) {
        animateOut()
    }
    
    @IBAction func whatChallenge(_ sender: UIButton) {
        animateInChallenge()
        let challenges = fortniteChallenges
        
        let index = Int(arc4random_uniform(UInt32(challenges.count)))
        
        challengeLabel.text = challenges[index]
        
        numberOfTaps += 1
        print(numberOfTaps)
        
        checkIfUserIsSusbcribed(completion: { isSusbcribed in
            if !isSusbcribed {
                if self.numberOfTaps >= 2 {
                    if self.interstitial.isReady {
                        self.interstitial.present(fromRootViewController: self)
                        self.numberOfTaps = 0
                    } else {
                        print("Ad wasn't ready")
                        self.numberOfTaps = 0
                    }
                }
            }
        })
    }
    
    @IBAction func dismissPopUpChallenge(_ sender: Any) {
        animateOutChallenge()
        
    }
    
    
    @IBAction func rateButton(_ sender: Any) {
        let appDelegate = AppDelegate()
        appDelegate.requestReview()
    }
    
    @IBAction func removeAdsButtonPressed(_ sender: Any) {
        let vc = UIHostingController(rootView: SusbcribeView())
        present(vc, animated: true)
    }
    
    func checkIfUserIsSusbcribed(completion: @escaping (Bool) -> Void) {
        Purchases.shared.getCustomerInfo { (customerInfo, error) in
            if let customerInfo = customerInfo {
                if customerInfo.entitlements[Constants.entitlementID]?.isActive == true {
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
