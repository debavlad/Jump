//
//  Trampoline.swift
//  Jump
//
//  Created by debavlad on 14.01.2020.
//  Copyright © 2020 Vladislav Deba. All rights reserved.
//

import Foundation
import SpriteKit

class Trampoline : Item {
	let anim: SKAction
	
	init(_ anim: SKAction) {
		self.anim = anim
		let n = SKSpriteNode(imageNamed: "batut0").px()
		n.position.y = 40
		n.setScale(6)
		n.physicsBody = SKPhysicsBody(rectangleOf: n.frame.size)
		n.physicsBody?.categoryBitMask = Bit.trampoline
		n.physicsBody?.contactTestBitMask = Bit.player
		n.physicsBody?.collisionBitMask = Bit.platform
		n.physicsBody?.friction = 0
		n.physicsBody?.restitution = 0
		n.zPosition = 4
		super.init(n)
	}
	
	override func execute() {
		node.run(anim)
	}
}
