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
	
	func hash(into hasher: inout Hasher) {
		hasher.combine(node)
	}
	
	static func == (lhs: Item, rhs: Item) -> Bool {
		return lhs.hashValue == rhs.hashValue
	}
}

extension SKSpriteNode {
	func fall() {
		physicsBody?.collisionBitMask = 0
		physicsBody?.contactTestBitMask = 0
		physicsBody?.categoryBitMask = 0
		physicsBody?.allowsRotation = true
		physicsBody?.isDynamic = true
	}
}
