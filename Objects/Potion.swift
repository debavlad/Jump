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
		let n = SKSpriteNode(imageNamed: Bool.random() ?
			PotionType.red.description : PotionType.yellow.description).px()
		n.setScale(6)
		n.position.y = 30
		n.physicsBody = SKPhysicsBody(rectangleOf: n.frame.size)
		n.physicsBody?.categoryBitMask = Categories.potion
		n.physicsBody?.contactTestBitMask = Categories.player
		n.physicsBody?.collisionBitMask = Categories.platform
		n.zPosition = 1
		super.init(n)
	}
}

enum PotionType: Int, CustomStringConvertible {
	case red
	case yellow
	
	var description: String {
		switch self {
			case .red: return "redpotion"
			case .yellow: return "yellowpotion"
		}
	}
}
