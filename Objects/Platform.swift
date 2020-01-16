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
  
	init(_ type: PlatformType, _ data: (texture: SKTexture, power: Int, damage: Int)) {
		self.type = type
		self.power = data.power
		self.damage = data.damage
		
		node = SKSpriteNode(texture: data.texture)
		node.size = CGSize(width: 117, height: 45)
		node.name = "platform"
		node.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 83.5, height: 1),
																		 center: CGPoint(x: 0, y: 20))
		node.physicsBody?.restitution = CGFloat(0.2)
		node.physicsBody?.friction = 0
		node.physicsBody?.mass = 10
		node.physicsBody?.linearDamping = 0
		node.physicsBody?.angularDamping = 0
		node.physicsBody?.contactTestBitMask = Categories.player
		node.physicsBody?.categoryBitMask = Categories.platform
		node.physicsBody?.collisionBitMask = Categories.coin | Categories.food
		node.physicsBody?.isDynamic = false
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
