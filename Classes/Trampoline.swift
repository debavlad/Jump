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
	init() {
		let n = SKSpriteNode(imageNamed: "batut0").px()
		n.position.y = 40
		n.setScale(6)
		n.physicsBody = SKPhysicsBody(rectangleOf: n.frame.size)
		n.physicsBody?.categoryBitMask = Categories.trampoline
		n.physicsBody?.contactTestBitMask = Categories.player
		n.physicsBody?.collisionBitMask = Categories.platform
		n.physicsBody?.friction = 0
		n.physicsBody?.restitution = 0
		n.zPosition = 3
		super.init(n)
	}
}
