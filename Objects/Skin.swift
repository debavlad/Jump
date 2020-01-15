//
//  Skin.swift
//  Jump
//
//  Created by debavlad on 01.01.2020.
//  Copyright © 2020 Vladislav Deba. All rights reserved.
//

import Foundation
import SpriteKit

class Skin {
	let name, title, dsc: String
	let texture: SKTexture
	let price: Int
	let currency: Currency
	let trailColors: [UIColor]
	
	init(name: String, title: String, dsc: String, _ price: Int, _ currency: Currency, colors: [UIColor]) {
		self.name = name
		self.title = title
		self.dsc = dsc
		texture = SKTexture(imageNamed: "\(name)-sit0").px()
		self.price = price
		self.currency = currency
		trailColors = colors
	}
}
