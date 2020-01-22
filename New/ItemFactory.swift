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
	private var coinAnims = [Currency : SKAction]()
	var set: Set<Item>
	
	init() {
		set = Set<Item>()
		foodEnergy = [
			.Meat: 25,
			.Chicken: 20,
			.Cheese: 20,
			.Bread: 15,
			.Egg: 15
		]
		
		var textures = [SKTexture]()
		for currency in Currency.allCases {
			for i in 0...7 {
				textures.append(SKTexture(imageNamed: "\(currency.rawValue)\(i)").px())
			}
			coinAnims[currency] = SKAction.animate(with: textures, timePerFrame: 0.1)
			textures.removeAll(keepingCapacity: true)
		}
	}
	
	func find(_ node: SKNode) -> Item {
		return set.first { (item) -> Bool in
			item.node == node
		}!
	}
	
	func randomFood() -> Food {
		let t = FoodType.allCases.randomElement()!
		let node = SKSpriteNode(imageNamed: t.rawValue)
			.foodOptions().itemDefaults().randomPos().px()
		node.name = "\(t.rawValue)item"
		let f = Food(node, foodEnergy[t]!)
		set.insert(f)
		return f
	}
	
	func randomCoin(_ available: Set<Currency>) -> Coin {
		let c = available.randomElement()!
		let node = SKSpriteNode().coinOptions().itemDefaults().px()
		node.name = "\(c.rawValue)item"
		node.run(SKAction.repeatForever(coinAnims[c]!))
		let coin = Coin(node, c)
		set.insert(coin)
		return coin
	}
	
	func randomPotion() -> Potion {
		let t = PotionType.allCases.randomElement()!
		let potion = Potion(t)
		potion.node.name = "\(t.rawValue)item"
		set.insert(potion)
		return potion
	}
}


extension SKSpriteNode {
	func randomPos() -> SKSpriteNode {
		position = CGPoint(x: CGFloat.random(in: -30...30), y: 30)
		zPosition = Bool.random() ? -1 : 2
		if Bool.random() { xScale = -6 }
		return self
	}

	func itemDefaults() -> SKSpriteNode {
		physicsBody?.isDynamic = false
		physicsBody?.contactTestBitMask = Categories.player
		physicsBody?.collisionBitMask = Categories.platform
		physicsBody?.friction = 0
		physicsBody?.restitution = 0
		return self
	}
	
	func foodOptions() -> SKSpriteNode {
		setScale(5.4)
		physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: size.width, height: size.height))
		physicsBody?.affectedByGravity = true
		physicsBody?.categoryBitMask = Categories.food
		return self
	}
	
	func coinOptions() -> SKSpriteNode {
		zPosition = 1
		size = CGSize(width: 54, height: 59.4)
		position = CGPoint(x: CGFloat.random(in: -20...20), y: 52)
		physicsBody = SKPhysicsBody(circleOfRadius: 35)
		physicsBody?.categoryBitMask = Categories.coin
		return self
	}
}
