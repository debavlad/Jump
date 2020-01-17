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
	init(_ type: PotionType) {
		let n = SKSpriteNode(imageNamed: type.rawValue).px()
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

enum PotionType: String, CaseIterable {
	case red, yellow
}
