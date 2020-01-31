//
//  FoodFactory.swift
//  Jump
//
//  Created by debavlad on 28.01.2020.
//  Copyright © 2020 Vladislav Deba. All rights reserved.
//

import Foundation
import SpriteKit

class FoodFactory : ItemFactory {
	static let shared = FoodFactory()
	private var foodEnergy : [FoodType : CGFloat]
	
	private init() {
		foodEnergy = [
			.Meat: 25,
			.Chicken: 20,
			.Cheese: 20,
			.Bread: 15,
			.Egg: 15
		]
	}
	
	func produce() -> Item {
		let type = FoodType.allCases.randomElement()!
		let node = SKSpriteNode(imageNamed: type.rawValue)
			.foodOptions().itemDefaults().randPos().px()
		node.name = "Fooditem"
		return Food(node, foodEnergy[type]!)
	}
}
