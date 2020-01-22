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
	let type: PotionType
	let poisoned: Bool
	
	init(_ type: PotionType) {
		self.type = type
		poisoned = type == .Red
		let n = SKSpriteNode(imageNamed: type.rawValue).px()
		n.setScale(6)
		n.position.y = 30
		n.physicsBody = SKPhysicsBody(rectangleOf: n.frame.size)
		n.physicsBody?.categoryBitMask = Bit.potion
		n.physicsBody?.contactTestBitMask = Bit.player
		n.physicsBody?.collisionBitMask = Bit.platform
		n.zPosition = 3
		super.init(n)
	}
}

enum PotionType: String, CaseIterable {
	case Red, Yellow
}
