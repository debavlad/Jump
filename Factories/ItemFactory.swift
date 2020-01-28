//
//  ItemFactory.swift
//  Jump
//
//  Created by debavlad on 15.01.2020.
//  Copyright © 2020 Vladislav Deba. All rights reserved.
//

import Foundation
import SpriteKit

protocol ItemFactory {
	func getInstance() -> Item
}

extension SKSpriteNode {
	func randPos() -> SKSpriteNode {
		position = CGPoint(x: CGFloat.random(in: -30...30), y: 30)
		zPosition = Bool.random() ? -1 : 2
		if Bool.random() { xScale = -6 }
		return self
	}
	
	func foodOptions() -> SKSpriteNode {
		setScale(5.4)
		physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: size.width, height: size.height))
		physicsBody?.affectedByGravity = true
		physicsBody?.categoryBitMask = Bit.food
		return self
	}
	
	func coinOptions() -> SKSpriteNode {
		zPosition = 1
		size = CGSize(width: 54, height: 59.4)
		position = CGPoint(x: CGFloat.random(in: -20...20), y: 52)
		physicsBody = SKPhysicsBody(circleOfRadius: 25)
		physicsBody?.categoryBitMask = Bit.coin
		return self
	}
	
	func potionOptions() -> SKSpriteNode {
		setScale(6)
		position.y = 40
		physicsBody = SKPhysicsBody(rectangleOf: frame.size)
		physicsBody?.categoryBitMask = Bit.potion
		zPosition = 3
		return self
	}

	func itemDefaults() -> SKSpriteNode {
		physicsBody?.isDynamic = false
		physicsBody?.allowsRotation = false
		physicsBody?.contactTestBitMask = Bit.player
		physicsBody?.collisionBitMask = Bit.platform
		physicsBody?.friction = 0
		physicsBody?.restitution = 0
		return self
	}
	
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
	
	func fall() {
		physicsBody?.collisionBitMask = 0
		physicsBody?.contactTestBitMask = 0
		physicsBody?.categoryBitMask = 0
		physicsBody?.allowsRotation = true
		physicsBody?.isDynamic = true
	}
}
