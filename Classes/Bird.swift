//
//  Bird.swift
//  Jump
//
//  Created by debavlad on 11.01.2020.
//  Copyright © 2020 Vladislav Deba. All rights reserved.
//

import Foundation
import SpriteKit

class Bird {
	let node: SKSpriteNode
	
	init(_ width: CGFloat, _ diff: CGFloat) {
		node = SKSpriteNode(imageNamed: "bird0").px()
		node.name = "bird"
		node.size = CGSize(width: 70, height: 50)
		node.position = CGPoint(x: width, y: diff)
		node.zPosition = 3
		node.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: node.size.width, height: 5))
		node.physicsBody?.isDynamic = false
		node.physicsBody?.categoryBitMask = Categories.bird
		node.physicsBody?.contactTestBitMask = Categories.player
		node.physicsBody?.collisionBitMask = 0
		node.physicsBody?.friction = 0
		node.physicsBody?.restitution = 0
		
		let left = SKAction.moveTo(x: -width, duration: 1.6)
		left.timingMode = .easeInEaseOut
		let right = SKAction.moveTo(x: width, duration: 1.6)
		right.timingMode = .easeInEaseOut
		let turn = SKAction.run { self.node.xScale = -self.node.xScale }
		node.run(SKAction.repeatForever(SKAction.sequence([turn, left, turn, right])))
		node.run(SKAction.repeatForever(SKAction.moveBy(x: 0, y: Bool.random() ? -50:50, duration: 1.2)))
	}
}
