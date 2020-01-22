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
	let node: SKSpriteNode
	let type: PlatformType
	var items: Set<Item>!
	private(set) var power, damage: Int
  
	init(_ type: PlatformType, _ data: (power: Int, damage: Int)) {
		self.type = type
		self.power = data.power
		self.damage = data.damage
		node = SKSpriteNode(texture: SKTexture(imageNamed: "\(type.rawValue)-platform")
			.px()).platformOptions()
	}
    
	func addItem(_ item: Item) {
		if items == nil { items = Set<Item>() }
		items.insert(item)
		node.addChild(item.node)
	}
	
	func hasItems() -> Bool {
		return items != nil && items.count > 0
	}
	
	func getItem(_ c: AnyClass) -> Item? {
		return items.first { (i) -> Bool in
			object_getClass(i) == c
		}
	}
	
	func moveX(_ w: CGFloat) {
		let r = SKAction.move(to: CGPoint(x: w, y: node.position.y), duration: 2)
		let l = SKAction.move(to: CGPoint(x: -w, y: node.position.y), duration: 2)
		r.timingMode = .easeInEaseOut; l.timingMode = .easeInEaseOut
		let seq = SKAction.sequence(node.position.x > 0 ? [l, r] : [r, l])
		node.run(SKAction.repeatForever(seq))
	}
	
	func moveY(_ h: CGFloat) {
		let lowest = node.position.y, highest = lowest + h
		let up = SKAction.move(to: CGPoint(x: node.position.x, y: highest), duration: 1.5)
		let down = SKAction.move(to: CGPoint(x: node.position.x, y: lowest), duration: 1.5)
		up.timingMode = .easeInEaseOut; down.timingMode = .easeInEaseOut
		node.run(SKAction.repeatForever(SKAction.sequence([up, down])))
	}
    
	func fall(_ contactX: CGFloat) {
		node.zPosition = -1
		node.fall()
		node.physicsBody?.applyAngularImpulse(contactX > node.position.x ? -0.1 : 0.1)
		
		if !hasItems() { return }
		for item in items {
			item.node.fall()
			item.node.physicsBody?.applyImpulse(CGVector(dx: 0, dy: -20))
		}
	}
}

extension SKSpriteNode {
	func platformOptions() -> SKSpriteNode {
		size = CGSize(width: 117, height: 45)
		name = "platform"
		physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 83.5, height: 1),
																		 center: CGPoint(x: 0, y: 20))
		physicsBody?.restitution = CGFloat(0.2)
		physicsBody?.friction = 0
		physicsBody?.mass = 10
		physicsBody?.linearDamping = 0
		physicsBody?.angularDamping = 0
		physicsBody?.contactTestBitMask = Bit.player
		physicsBody?.categoryBitMask = Bit.platform
		physicsBody?.collisionBitMask = Bit.coin | Bit.food
		physicsBody?.isDynamic = false
		return self
	}
}
