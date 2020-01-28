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
	func getInstance() -> Item {
		let type = PotionType.allCases.randomElement()!
		let node = SKSpriteNode(imageNamed: type.rawValue)
			.potionOptions().itemDefaults().px()
		node.name = "\(type.rawValue)item"
		return Potion(node, type == .Red)
	}
}
