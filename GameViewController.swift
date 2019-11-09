//
//  GameViewController.swift
//  Jump
//
//  Created by Vladislav Deba on 7/30/19.
//  Copyright © 2019 Vladislav Deba. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import GoogleMobileAds

class GameViewController: UIViewController, GADRewardedAdDelegate {
    func rewardedAd(_ rewardedAd: GADRewardedAd, userDidEarn reward: GADAdReward) {
        GameScene.adWatched = true
    }
    

    var myAd = GADRewardedAd()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "GameScene") {
                // Set the scale mode to scale to fit the window
                scene.size = CGSize(width: view.frame.width*2, height: view.frame.height*2)
                scene.scaleMode = .aspectFill
                // Present the scene
                view.presentScene(scene)
                
                NotificationCenter.default.addObserver(self, selector: #selector(GameViewController.showAd), name: NSNotification.Name(rawValue: "showAd"), object: nil)
                NotificationCenter.default.addObserver(self, selector: #selector(GameViewController.loadAd), name: NSNotification.Name(rawValue: "loadAd"), object: nil)
                loadAd()
            }
            
            view.ignoresSiblingOrder = true
            
//            view.showsPhysics = true
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @objc func loadAd() {
        myAd = GADRewardedAd.init(adUnitID: TEST_AD_ID)
        let request = GADRequest()
        request.testDevices = [ "b4e79107e711a12cec41bd7ce2f77af7" ]
        myAd.load(request, completionHandler: nil)
        print("Load Ad")
    }
    
    @objc func showAd() {
        if myAd.isReady {
            myAd.present(fromRootViewController: self, delegate: self)
            print("Show Ad")
        }
    }
}
