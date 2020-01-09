//
//  Coin.swift
//  Jump
//
//  Created by debavlad on 02.01.2020.
//  Copyright © 2020 Vladislav Deba. All rights reserved.
//

import Foundation
import SpriteKit

class Coin: Item {
	private(set) var currency: Currency
	
	init(_ node: SKSpriteNode, _ curr: Currency) {
		self.currency = curr
		super.init(node)
	}
}
