//
//  Food.swift
//  Jump
//
//  Created by debavlad on 02.01.2020.
//  Copyright © 2020 Vladislav Deba. All rights reserved.
//

import Foundation
import SpriteKit

class Food: Item {
	private(set) var energy: Int
	
	init(_ node: SKSpriteNode, _ energy: Int) {
		self.energy = energy
		super.init(node)
	}
}
