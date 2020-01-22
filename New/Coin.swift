//
//  Coin.swift
//  Jump
//
//  Created by debavlad on 02.01.2020.
//  Copyright © 2020 Vladislav Deba. All rights reserved.
//

import Foundation
import SpriteKit

class Coin: Item {
	private(set) var currency: Currency
	
	init(_ node: SKSpriteNode, _ curr: Currency) {
		self.currency = curr
		super.init(node)
	}
}

enum Currency: String, CaseIterable {
	case Wood, Bronze, Golden
}

extension SKSpriteNode {
	func coinOptions() -> SKSpriteNode {
		zPosition = 1
		size = CGSize(width: 54, height: 59.4)
		position = CGPoint(x: CGFloat.random(in: -20...20), y: 52)
		physicsBody = SKPhysicsBody(circleOfRadius: 25)
		physicsBody?.categoryBitMask = Bit.coin
		return self
	}
}
