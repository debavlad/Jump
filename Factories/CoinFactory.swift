//
//  CoinFactory.swift
//  Jump
//
//  Created by debavlad on 28.01.2020.
//  Copyright © 2020 Vladislav Deba. All rights reserved.
//

import Foundation
import SpriteKit

class CoinFactory: ItemFactory {
	static let shared = CoinFactory()
	private var anim: SKAction
	
	private init() {
		var arr = [SKTexture]()
		for i in 0...7 {
			arr.append(SKTexture(imageNamed: "Coin\(i)").px())
		}
		anim = SKAction.animate(with: arr, timePerFrame: 0.1)
		arr.removeAll()
	}
	
	func produce() -> Item {
		let node = SKSpriteNode().coinOptions().itemDefaults().px()
		node.name = "Coinitem"
		node.run(SKAction.repeatForever(anim))
		return Coin(node)
	}
}
