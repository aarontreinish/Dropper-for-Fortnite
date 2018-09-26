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

class ViewController: UIViewController, GADBannerViewDelegate {
    
    @IBOutlet weak var bannerView: GADBannerView!
    
    @IBOutlet var locationView: UIView!
    
    @IBOutlet var challengeView: UIView!
    
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    
    @IBOutlet weak var locationLabel: UILabel!
    
    @IBOutlet weak var challengeLabel: UILabel!
    
    
    @IBOutlet weak var dropLocation: UIButton!
    
    
    @IBOutlet weak var whatChallenge: UIButton!
    
    
    var fortniteLocations = ["Junk Junction", "Haunted Hills", "Pleasant Park", "Snobby Shores", "Soccer Field", "Viking Village", "Flush Factory", "The Factoy", "Big Chair", "Shifty Shafts", "Tilted Towers", "Loot Lake", "Lazy Links", "Dusty Divot", "Salty Springs", "Fatal Fields", "Lucky Landing", "Paradise Palms", "Retail Row", "Shipment Yard", "Tomato Temple", " Risky Reels", "Wailing Woods", "Lonely Lodge", "Race Track", "Super Villain Base", "Giant Lama"]
    
    var fortniteChallenges = ["0 Kill Win Challenge", "No Meds Challenge", "One Gun Only Challenge", "Impulse Only Challenge", "Grenade Only Challenge", "C4 Only Challenge", "Traps Only Challenge", "Sniper Only Challenge", "Pistol Only Challenge", "Hand Cannon Only Challenge", "One Chest Only Challenge", "Hunting Rifle Only Challenge", "No Reload Challenge", "Minigun Only Challenge", "No Gun Challenge", "No Building Challenge", "SMG Only Challenge", "Silenced Guns Only Challenge", "Floor is Lava Challenge", "Apples Only Challenge", "Mushrooms Only Challenge", "Rainbow Gun Challenge", "Pickaxe Only Challenge", "Shotgun Only Challenge", "Stink Bomb Only Challenge", "Clingers Only Challenge", "Vending Machines Only Challenge", "Rocket Launcher Only Challenge", "Grenade Launcher Only Challenge", "Revolver Only Challenge", "Gray Guns Only Challenge", "Pick up Enemy's Loadout Challenge"]
    
    var effect: UIVisualEffect!

    
    var audioPlayer = AVAudioPlayer()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        effect = visualEffectView.effect
        visualEffectView.effect = nil
        
        locationView.layer.cornerRadius = 10
        challengeView.layer.cornerRadius = 10
        
        self.bannerView.adUnitID = "ca-app-pub-7930281625187952/3947297105"
        self.bannerView.rootViewController = self
        bannerView.load(GADRequest())
        bannerView.delegate = self
        
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: "Hang Glider Sound", ofType: "mp3")!))
            audioPlayer.prepareToPlay()
        }
        catch {
            print(error)
        }
        
    }
    
    func animateIn() {
        self.view.addSubview(locationView)
        locationView.center = self.view.center
        
        locationView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
        locationView.alpha = 0
        
        audioPlayer.play()
        
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
        audioPlayer.stop()
        audioPlayer.currentTime = 0
        
        whatChallenge.isEnabled = true
        dropLocation.isEnabled = true
        
    }
    
    func animateInChallenge() {
        self.view.addSubview(challengeView)
        challengeView.center = self.view.center
        
        challengeView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
        challengeView.alpha = 0
        
        audioPlayer.play()
        
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

       audioPlayer.stop()
       audioPlayer.currentTime = 0
        
       dropLocation.isEnabled = true
       whatChallenge.isEnabled = true
        
    }
    
    
    @IBAction func dropLocation(_ sender: UIButton) {
        animateIn()
        fortniteLocations = ["Junk Junction", "Haunted Hills", "Pleasant Park", "Snobby Shores", "Soccer Field", "Viking Village", "Flush Factory", "The Factoy", "Big Chair", "Shifty Shafts", "Tilted Towers", "Loot Lake", "Lazy Links", "Dusty Divot", "Salty Springs", "Fatal Fields", "Lucky Landing", "Paradise Palms", "Retail Row", "Shipment Yard", "Tomato Temple", " Risky Reels", "Wailing Woods", "Lonely Lodge", "Race Track", "Super Villain Base", "Giant Lama"]
        
        let index = Int(arc4random_uniform(UInt32(fortniteLocations.count)))
        
        locationLabel.text = fortniteLocations[index]
    
        
    }
    
    
    
    @IBAction func dismissPopUp(_ sender: Any) {
        animateOut()
    }
    
    @IBAction func whatChallenge(_ sender: UIButton) {
        animateInChallenge()
        fortniteChallenges = ["0 Kill Win Challenge", "No Meds Challenge", "One Gun Only Challenge", "Impulse Only Challenge", "Grenade Only Challenge", "C4 Only Challenge", "Traps Only Challenge", "Sniper Only Challenge", "Pistol Only Challenge", "Hand Cannon Only Challenge", "One Chest Only Challenge", "Hunting Rifle Only Challenge", "No Reload Challenge", "Minigun Only Challenge", "No Gun Challenge", "No Building Challenge", "SMG Only Challenge", "Silenced Guns Only Challenge", "Floor is Lava Challenge", "Apples Only Challenge", "Mushrooms Only Challenge", "Rainbow Gun Challenge", "Pickaxe Only Challenge", "Shotgun Only Challenge", "Stink Bomb Only Challenge", "Clingers Only Challenge", "Vending Machines Only Challenge", "Rocket Launcher Only Challenge", "Grenade Launcher Only Challenge", "Revolver Only Challenge", "Gray Guns Only Challenge", "Pick up Enemy's Loadout Challenge"]
        
        let index = Int(arc4random_uniform(UInt32(fortniteChallenges.count)))
        
        challengeLabel.text = fortniteChallenges[index]
        
    }
    
    @IBAction func dismissPopUpChallenge(_ sender: Any) {
        animateOutChallenge()
        
    }
    
    
    @IBAction func rateButton(_ sender: Any) {
        let appDelegate = AppDelegate()
        appDelegate.requestReview()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

