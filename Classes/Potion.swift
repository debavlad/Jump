//
//  Potion.swift
//  Jump
//
//  Created by debavlad on 14.01.2020.
//  Copyright © 2020 Vladislav Deba. All rights reserved.
//

import Foundation
import SpriteKit

class Potion : Item {
	init() {
		let n = SKSpriteNode(imageNamed: Bool.random() ? "potion1" : "potion2").px()
		n.setScale(6)
		n.position.y = 30
		n.physicsBody = SKPhysicsBody(rectangleOf: n.frame.size)
		n.physicsBody?.categoryBitMask = Categories.potion
		n.physicsBody?.contactTestBitMask = Categories.player
		n.physicsBody?.collisionBitMask = Categories.platform
		n.zPosition = 3
		super.init(n)
	}
}
