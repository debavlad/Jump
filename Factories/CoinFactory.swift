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
	private var anims: [Currency : SKAction]
	
	init() {
		anims = [Currency : SKAction]()
		var arr = [SKTexture]()
		for c in Currency.allCases {
			for i in 0...7 {
				arr.append(SKTexture(imageNamed: "\(c.rawValue)\(i)").px())
			}
			anims[c] = SKAction.animate(with: arr, timePerFrame: 0.1)
			arr.removeAll(keepingCapacity: true)
		}
		arr.removeAll()
	}
	
	func getInstance() -> Item {
		let type = Currency.allCases.randomElement()!
		let node = SKSpriteNode().coinOptions().itemDefaults().px()
		node.name = "\(type.rawValue)item"
		node.run(SKAction.repeatForever(anims[type]!))
		return Coin(node, type)
	}
}
