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
	private var foodEnergy : [FoodType : CGFloat]
	
	init() {
		let coef = CGFloat(Skins[GameScene.skinIndex].name == "farmer" ? 1.25 : 1)
		foodEnergy = [
			.Meat: 25,
			.Chicken: 20,
			.Cheese: 20,
			.Bread: 15,
			.Egg: 15
		]
		
		for type in FoodType.allCases {
			foodEnergy[type]! *= coef
		}
	}
	
	func getInstance() -> Item {
		let type = FoodType.allCases.randomElement()!
		let node = SKSpriteNode(imageNamed: type.rawValue)
			.foodOptions().itemDefaults().randPos().px()
		node.name = "\(type.rawValue)item"
		return Food(node, foodEnergy[type]!)
	}
}
