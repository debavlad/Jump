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

class GameViewController: UIViewController {
	override func viewDidLoad() {
		super.viewDidLoad()
		
		if let view = self.view as! SKView? {
			if let scene = SKScene(fileNamed: "GameScene") {
				scene.size = CGSize(width: view.frame.width*2, height: view.frame.height*2)
				scene.scaleMode = .aspectFill
				view.presentScene(scene)
				
				view.showsNodeCount = true
				view.showsDrawCount = true
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
}
