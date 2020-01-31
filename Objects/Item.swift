//
//  Item.swift
//  Jump
//
//  Created by debavlad on 22.01.2020.
//  Copyright © 2020 Vladislav Deba. All rights reserved.
//

import Foundation
import SpriteKit

class Item: Hashable {
	let node: SKSpriteNode
	var intersected: Bool
	
	init(_ node: SKSpriteNode) {
		self.node = node
		intersected = false
	}
	
	func hash(into hasher: inout Hasher) {
		hasher.combine(node)
	}

	static func == (lhs: Item, rhs: Item) -> Bool {
		return lhs.hashValue == rhs.hashValue
	}
}
