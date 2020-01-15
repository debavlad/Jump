//
//  Bird.swift
//  Jump
//
//  Created by debavlad on 11.01.2020.
//  Copyright © 2020 Vladislav Deba. All rights reserved.
//

import Foundation
import SpriteKit

class Bird : Hashable {
	let node: SKSpriteNode
	
	init(_ width: CGFloat, _ diff: CGFloat) {
		let rand = Bool.random()
		node = SKSpriteNode(imageNamed: "bird0").px()
		node.name = "bird"
		node.zPosition = 3
		node.size = CGSize(width: 70, height: 50)
		node.position = CGPoint(x: rand ? width : -width, y: diff)
		node.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: node.size.width, height: 5))
		node.physicsBody?.categoryBitMask = Categories.bird
		node.physicsBody?.contactTestBitMask = Categories.player
		node.physicsBody?.collisionBitMask = 0
		node.physicsBody?.isDynamic = false
		node.physicsBody?.friction = 0
		node.physicsBody?.restitution = 0
		
		let l = SKAction.moveTo(x: -width, duration: 1.6)
		let r = SKAction.moveTo(x: width, duration: 1.6)
		l.timingMode = .easeInEaseOut; r.timingMode = .easeInEaseOut
		let turn = SKAction.run { self.node.xScale = -self.node.xScale }
		node.run(SKAction.repeatForever(SKAction.sequence(rand ? [turn, l, turn, r] : [r, turn, l, turn])))
		node.run(SKAction.repeatForever(SKAction.moveBy(x: 0, y: Bool.random() ? -90 : 90, duration: 1.2)))
	}
	
	func hash(into hasher: inout Hasher) {
		hasher.combine(node)
	}
	
	static func == (lhs: Bird, rhs: Bird) -> Bool {
		return lhs.hashValue == rhs.hashValue
	}
}
