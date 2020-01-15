//
//  ItemFactory.swift
//  Jump
//
//  Created by debavlad on 15.01.2020.
//  Copyright © 2020 Vladislav Deba. All rights reserved.
//

import Foundation
import SpriteKit

class ItemFactory {
	private var foodEnergy = [FoodType : Int]()
	private var coinAnims = [String : SKAction]()
	
	init() {
		foodEnergy[FoodType.meat] = 25
		foodEnergy[FoodType.chicken] = 20
		foodEnergy[FoodType.cheese] = 20
		foodEnergy[FoodType.bread] = 15
		foodEnergy[FoodType.egg] = 15
		
		var textures = [SKTexture]()
		for i in 0...7 {
			textures.append(SKTexture(imageNamed: "wood\(i)").px())
		}
		coinAnims["wood"] = SKAction.animate(with: textures, timePerFrame: 0.1)
		textures.removeAll(keepingCapacity: true)
		
		for i in 0...7 {
			textures.append(SKTexture(imageNamed: "bronze\(i)").px())
		}
		coinAnims["bronze"] = SKAction.animate(with: textures, timePerFrame: 0.1)
		textures.removeAll(keepingCapacity: true)
		
		for i in 0...7 {
			textures.append(SKTexture(imageNamed: "golden\(i)").px())
		}
		coinAnims["golden"] = SKAction.animate(with: textures, timePerFrame: 0.1)
		textures.removeAll()
	}
	
	func randomFood() -> Food {
		let rand = Int.random(in: 0..<foodEnergy.count)
		let type = FoodType(rawValue: rand)!
		let node = SKSpriteNode(imageNamed: type.description)
			.applyFoodProperties().randomizePosition().px()
		node.name = "\(type.description)item"
		return Food(node, foodEnergy[type]!)
	}
	
	func randomCoin(_ available: [Currency]) -> Coin {
		let node = SKSpriteNode().applyCoinProperties().px()
		let currency = available[Int.random(in: 0..<available.count)]
		node.name = "\(currency.description)item"
		let anim = coinAnims[currency.description]!
		node.run(SKAction.repeatForever(anim))
		return Coin(node, currency)
	}
}

enum FoodType: Int, CustomStringConvertible {
	case meat
	case chicken
	case cheese
	case bread
	case egg
	
	var description: String {
		switch self {
		case .chicken: return "chicken"
		case .bread: return "bread"
		case .cheese: return "cheese"
		case .egg: return "egg"
		case .meat: return "meat"
		}
	}
}

enum Currency : CustomStringConvertible {
	case wood
	case bronze
	case golden
	
	var description: String {
			switch self {
			case .wood: return "wood"
			case .bronze: return "bronze"
			case .golden: return "golden"
			}
	}
}

extension SKSpriteNode {
	func randomizePosition() -> SKSpriteNode {
		position = CGPoint(x: CGFloat.random(in: -30...30), y: 30)
		zPosition = Bool.random() ? -1 : 2
		if Bool.random() { xScale = -6 }
		return self
	}
	
	func applyFoodProperties() -> SKSpriteNode {
		setScale(5.4)
		physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: size.width, height: size.height))
		physicsBody?.affectedByGravity = true
		physicsBody?.categoryBitMask = Categories.food
		physicsBody?.contactTestBitMask = Categories.player
		physicsBody?.collisionBitMask = Categories.platform
		physicsBody?.friction = 0
		physicsBody?.restitution = 0
		physicsBody?.isDynamic = false
		return self
	}
	
	func applyCoinProperties() -> SKSpriteNode {
		size = CGSize(width: 54, height: 59.4)
		zPosition = 1
		position = CGPoint(x: CGFloat.random(in: -20...20), y: 52)
		physicsBody = SKPhysicsBody(circleOfRadius: 35)
		physicsBody?.isDynamic = false
		physicsBody?.categoryBitMask = Categories.coin
		physicsBody?.contactTestBitMask = Categories.player
		physicsBody?.collisionBitMask = Categories.platform
		physicsBody?.friction = 0
		physicsBody?.restitution = 0
		return self
	}
}
