//
//  Item.swift
//  Jump
//
//  Created by debavlad on 8/25/19.
//  Copyright © 2019 Vladislav Deba. All rights reserved.
//

import Foundation
import SpriteKit

class Item: Hashable {
	let node: SKSpriteNode
	var wasTouched = false
	
	init(_ node: SKSpriteNode) {
		self.node = node
	}
	
	func fall() {
		node.physicsBody?.collisionBitMask = 0
		node.physicsBody?.contactTestBitMask = 0
		node.physicsBody?.categoryBitMask = 0
		node.physicsBody?.allowsRotation = true
		node.physicsBody?.isDynamic = true
	}
	
	func hash(into hasher: inout Hasher) {
			hasher.combine(node)
	}
	
	static func == (lhs: Item, rhs: Item) -> Bool {
			return lhs.hashValue == rhs.hashValue
	}
}

class Coin: Item {
	private(set) var currency: Currency
	
	init(_ node: SKSpriteNode, _ currency: Currency) {
		self.currency = currency
		super.init(node)
	}
}

class Food: Item {
	private(set) var energy: Int
	
	init(_ node: SKSpriteNode, _ energy: Int) {
		self.energy = energy
		super.init(node)
	}
}
