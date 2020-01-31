//
//  PotionFactory.swift
//  Jump
//
//  Created by debavlad on 28.01.2020.
//  Copyright © 2020 Vladislav Deba. All rights reserved.
//

import Foundation
import SpriteKit

class PotionFactory: ItemFactory {
	static let shared = PotionFactory()
	
	func produce() -> Item {
		let type = PotionType.allCases.randomElement()!
		let node = SKSpriteNode(imageNamed: type.rawValue)
			.potionOptions().itemDefaults().px()
		node.name = "\(type.rawValue)item"
		return Potion(node, type == .Red)
	}
}
