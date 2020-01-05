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
//import GoogleMobileAds

class GameViewController: UIViewController {
//	func rewardedAd(_ rewardedAd: GADRewardedAd, userDidEarn reward: GADAdReward) {
//		NotificationCenter.default.post(name: NSNotification.Name(rawValue: "adWatchedUI"), object: nil)
//	}
	
//	var rewardedAd: GADRewardedAd!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		if let view = self.view as! SKView? {
			if let scene = SKScene(fileNamed: "GameScene") {
				scene.size = CGSize(width: view.frame.width*2, height: view.frame.height*2)
				scene.scaleMode = .aspectFill
				view.presentScene(scene)
					
//				rewardedAd = GADRewardedAd(adUnitID: ADMOB_AD_ID)
//				NotificationCenter.default.addObserver(self, selector: #selector(GameViewController.showAd), name: NSNotification.Name(rawValue: "showAd"), object: nil)
//				NotificationCenter.default.addObserver(self, selector: #selector(GameViewController.loadAd), name: NSNotification.Name(rawValue: "loadAd"), object: nil)
			}
			
			view.ignoresSiblingOrder = true
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
	
//	@objc func loadAd() {
//		let request = GADRequest()
//		request.testDevices = ["b4e79107e711a12cec41bd7ce2f77af7"]
//		rewardedAd.load(request) { (error) in
//			if (error != nil) {
//				print(error.debugDescription)
//			} else {
//				print("Successfully loaded")
//			}
//		}
//	}
//
//	@objc func showAd() {
//		if rewardedAd.isReady {
//			rewardedAd.present(fromRootViewController: self, delegate: self)
//		}
//	}
}
