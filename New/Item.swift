//
//  Item.swift
//  Jump
//
//  Created by debavlad on 22.01.2020.
//  Copyright © 2020 Vladislav Deba. All rights reserved.
//

import Foundation
import SpriteKit

class Item: Hashable {
	let node: SKSpriteNode
	var intersected: Bool
	
	init(_ node: SKSpriteNode) {
		self.node = node
		intersected = false
	}
	
	func execute() {
		let name = "\(node.name!.dropLast(4))"
		guard let em = SKEmitterNode(fileNamed: name) else { return }
		if let parent = node.parent, let world = parent.parent {
			em.position = CGPoint(x: parent.position.x + node.position.x,
														y: parent.position.y + node.position.y)
			em.zPosition = 3
			world.addChild(em)
		}
		node.removeFromParent()
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
