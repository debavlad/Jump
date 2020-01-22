//
//  Block.swift
//  Jump
//
//  Created by debavlad on 22.01.2020.
//  Copyright © 2020 Vladislav Deba. All rights reserved.
//

import Foundation
import SpriteKit

class Block: Hashable {
	let node: SKSpriteNode
	var items: Set<Item>?
	let type: BlockType
	let power, damage: Int
	
	init(_ type: BlockType, _ data: (Int, Int)) {
		self.type = type
		node = SKSpriteNode(imageNamed: type.rawValue).blockOptions().px()
		items = nil
		power = data.0
		damage = data.1
	}
	
	func addItem(_ item: Item) {
		if items == nil {
			items = Set<Item>()
		}
		items!.insert(item)
		node.addChild(item.node)
	}
	
	func hash(into hasher: inout Hasher) {
		hasher.combine(node)
	}
	
	static func == (lhs: Block, rhs: Block) -> Bool {
		return lhs.hashValue == rhs.hashValue
	}
}

extension SKSpriteNode {
	func blockOptions() -> SKSpriteNode {
		name = "platform"
		size = CGSize(width: 117, height: 45)
		physicsBody = SKPhysicsBody(rectangleOf:
			CGSize(width: 83.5, height: 1), center: CGPoint(x: 0, y: 20))
		physicsBody?.restitution = 0.2
		physicsBody?.friction = 0
		physicsBody?.mass = 10
		physicsBody?.linearDamping = 0
		physicsBody?.angularDamping = 0
		physicsBody?.contactTestBitMask = Bit.player
		physicsBody?.categoryBitMask = Bit.platform
		physicsBody?.collisionBitMask = Bit.coin | Bit.food | Bit.potion
		physicsBody?.isDynamic = false
		return self
	}
}

enum BlockType: String, CaseIterable {
	case Dirt, Sand, Wooden, Stone
}
