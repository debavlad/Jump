//
//  Platform.swift
//  Jump
//
//  Created by debavlad on 8/18/19.
//  Copyright © 2019 Vladislav Deba. All rights reserved.
//

import Foundation
import SpriteKit

class Platform {
	let node: SKSpriteNode!
	let type: PlatformType
	private(set) var items: Set<Item>!
	private(set) var power, damage: Int
    
	init(_ type: PlatformType, _ data: (texture: SKTexture, power: Int, damage: Int)) {
		self.type = type
		node = SKSpriteNode(texture: data.texture)
		node.size = CGSize(width: 117, height: 45)
		node.name = "platform"
		node.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 83.5, height: 1), center: CGPoint(x: 0, y: 20))
		node.physicsBody?.restitution = CGFloat(0.2)
		node.physicsBody?.friction = 0
		node.physicsBody?.mass = 10
		node.physicsBody?.linearDamping = 0
		node.physicsBody?.angularDamping = 0
		node.physicsBody?.contactTestBitMask = Categories.player
		node.physicsBody?.categoryBitMask = Categories.platform
		node.physicsBody?.collisionBitMask = Categories.coin | Categories.food
		node.physicsBody?.isDynamic = false
		
		self.damage = data.damage
		self.power = data.power
	}
    
	func addItem(_ item: Item) {
		if items == nil { items = Set<Item>() }
		items.insert(item)
		node.addChild(item.node)
	}
    
	func removeItem(_ item: Item) {
		items.remove(item)
		item.node.removeFromParent()
	}
	
	func hasItems() -> Bool {
		return items != nil && items.count > 0
	}
    
	func moveByX(_ width: CGFloat) {
		let right = SKAction.move(to: CGPoint(x: width, y: node.position.y), duration: 2)
		right.timingMode = .easeInEaseOut
		let left = SKAction.move(to: CGPoint(x: -width, y: node.position.y), duration: 2)
		left.timingMode = .easeInEaseOut
		let seq = node.position.x > 0 ? SKAction.sequence([left, right]) : SKAction.sequence([right, left])
		node.run(SKAction.repeatForever(seq))
	}
    
	func moveByY(_ height: CGFloat) {
		let minY = node.position.y, highest = node.position.y + height
		let up = SKAction.move(to: CGPoint(x: node.position.x, y: highest), duration: 1.5)
		up.timingMode = .easeInEaseOut
		let down = SKAction.move(to: CGPoint(x: node.position.x, y: minY), duration: 1.5)
		down.timingMode = .easeInEaseOut
		node.run(SKAction.repeatForever(SKAction.sequence([up, down])))
	}
    
	func fall(_ contactX: CGFloat) {
		node.zPosition = -1
		node.physicsBody?.collisionBitMask = 0
		node.physicsBody?.contactTestBitMask = 0
		node.physicsBody?.categoryBitMask = 0
		node.physicsBody?.isDynamic = true
		node.physicsBody?.allowsRotation = true
		node.physicsBody?.applyAngularImpulse(contactX > node.position.x ? -0.1 : 0.1)
		
		if !hasItems() { return }
		for item in items {
			item.fall()
			item.node.physicsBody?.applyImpulse(CGVector(dx: 0, dy: -20))
		}
	}
}
