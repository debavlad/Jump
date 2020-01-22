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
	private let trampAnim: SKAction
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
		trampAnim = SKAction.animate(with: [SKTexture(imageNamed: "batut1"),
		  SKTexture(imageNamed: "batut0")], timePerFrame: 0.1)
	}
	
	func find(_ node: SKNode) -> Item {
		return set.first { (item) -> Bool in
			item.node == node
		}!
	}
	
	func getFood() -> Food {
		let t = FoodType.allCases.randomElement()!
		let node = SKSpriteNode(imageNamed: t.rawValue)
			.foodOptions().itemDefaults().randPos().px()
		node.name = "\(t.rawValue)item"
		let f = Food(node, foodEnergy[t]!)
		set.insert(f)
		return f
	}
	
	func getTrampoline() -> Trampoline {
		return Trampoline(trampAnim)
	}
	
	func getCoin() -> Coin {
		let t = Currency.allCases.randomElement()!
		let node = SKSpriteNode().coinOptions().itemDefaults().px()
		node.name = "\(t.rawValue)item"
		node.run(SKAction.repeatForever(coinAnims[t]!))
		let c = Coin(node, t)
		set.insert(c)
		return c
	}
	
	func getPotion() -> Potion {
		let t = PotionType.allCases.randomElement()!
		let potion = Potion(t)
		potion.node.name = "\(t.rawValue)item"
		set.insert(potion)
		return potion
	}
}


extension SKSpriteNode {
	func randPos() -> SKSpriteNode {
		position = CGPoint(x: CGFloat.random(in: -30...30), y: 30)
		zPosition = Bool.random() ? -1 : 2
		if Bool.random() { xScale = -6 }
		return self
	}

	func itemDefaults() -> SKSpriteNode {
		physicsBody?.isDynamic = false
		physicsBody?.contactTestBitMask = Bit.player
		physicsBody?.collisionBitMask = Bit.platform
		physicsBody?.friction = 0
		physicsBody?.restitution = 0
		return self
	}
}
