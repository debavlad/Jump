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
	
	func vertMove(_ dist: CGFloat) {
		let bottom = node.position.y, top = bottom + dist, speed = Double.random(in: 1.35...1.65)
		let up = SKAction.move(to: CGPoint(x: node.position.x, y: top), duration: speed)
		let down = SKAction.move(to: CGPoint(x: node.position.x, y: bottom), duration: speed)
		up.timingMode = .easeInEaseOut; down.timingMode = .easeInEaseOut
		node.run(SKAction.repeatForever(SKAction.sequence([up, down])))
	}
	
	func horMove(_ dist: CGFloat) {
		let speed = Double.random(in: 1.85...2.15)
		let right = SKAction.move(to: CGPoint(x: dist, y: node.position.y), duration: speed)
		let left = SKAction.move(to: CGPoint(x: -dist, y: node.position.y), duration: speed)
		right.timingMode = .easeInEaseOut; left.timingMode = .easeInEaseOut
		node.run(SKAction.repeatForever(SKAction.sequence(node.position.x > 0 ?
			[left, right] : [right, left])))
	}
	
	func isEmpty() -> Bool {
		return items == nil || items?.count == 0
	}
	
	func addItem(_ item: Item) {
		if items == nil {
			items = Set<Item>()
		}
		items!.insert(item)
		node.addChild(item.node)
	}
	
	func fall(_ contactX: CGFloat) {
		node.fall()
		node.physicsBody?.applyAngularImpulse(contactX > node.position.x ? -0.1 : 0.1)
		if isEmpty() { return }
		for item in items! {
			item.node.fall()
			item.node.physicsBody?.applyImpulse(CGVector(dx: 0, dy: -20))
		}
	}
	//	func fall(_ contactX: CGFloat) {
	//		node.zPosition = -1
	//		node.fall()
	//		node.physicsBody?.applyAngularImpulse(contactX > node.position.x ? -0.1 : 0.1)
	//
	//		if !hasItems() { return }
	//		for item in items {
	//			item.node.fall()
	//			item.node.physicsBody?.applyImpulse(CGVector(dx: 0, dy: -20))
	//		}
	//	}
	
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
			CGSize(width: 85, height: 1), center: CGPoint(x: 0, y: 20))
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
