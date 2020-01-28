//
//  Potion.swift
//  Jump
//
//  Created by debavlad on 14.01.2020.
//  Copyright © 2020 Vladislav Deba. All rights reserved.
//

import Foundation
import SpriteKit

class Potion: Item {
	private(set) var poisoned: Bool
	
	init(_ node: SKSpriteNode, _ poisoned: Bool) {
		self.poisoned = poisoned
		super.init(node)
	}
}

enum PotionType: String, CaseIterable {
	case Red, Yellow
}
