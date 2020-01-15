//
//  Food.swift
//  Jump
//
//  Created by Vladislav Deba on 8/7/19.
//  Copyright © 2019 Vladislav Deba. All rights reserved.
//

import Foundation
import SpriteKit

//class FoodFactory {
//	private var energies = [FoodType : Int]()
//
//	init() {
//		energies[FoodType.meat] = 25
//		energies[FoodType.chicken] = 20
//		energies[FoodType.cheese] = 20
//		energies[FoodType.bread] = 15
//		energies[FoodType.egg] = 15
//	}
//
//	func getRandomFood() -> Food {
//		let index = Int.random(in: 0..<energies.count)
//		let type = FoodType(rawValue: index)
//		let food = create(type!)
//		return food
//	}
//
//	private func create(_ type: FoodType) -> Food {
//		let node = SKSpriteNode(imageNamed: type.description)
//				.applyFoodSettings()
//				.randomize()
//				.px()
//		node.name = type.description + "item"
//
//		return Food(node, energies[type]!)
//	}
//}
//
//enum FoodType: Int, CustomStringConvertible {
//	case meat
//	case chicken
//	case cheese
//	case bread
//	case egg
//
//	var description: String {
//		switch self {
//		case .chicken: return "chicken"
//		case .bread: return "bread"
//		case .cheese: return "cheese"
//		case .egg: return "egg"
//		case .meat: return "meat"
//		}
//	}
//}
//
//extension SKSpriteNode {
//	func randomize() -> SKSpriteNode {
//		position = CGPoint(x: CGFloat.random(in: -30...30), y: 30)
//		zPosition = Bool.random() ? -1 : 2
//		if Bool.random() { xScale = -6 }
//		return self
//	}
//
//	func applyFoodSettings() -> SKSpriteNode {
//		setScale(5.4)
//		physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: size.width, height: size.height))
//		physicsBody?.affectedByGravity = true
//		physicsBody?.categoryBitMask = Categories.food
//		physicsBody?.contactTestBitMask = Categories.player
//		physicsBody?.collisionBitMask = Categories.platform
//		physicsBody?.friction = 0
//		physicsBody?.restitution = 0
//		physicsBody?.isDynamic = false
//		return self
//	}
//}
