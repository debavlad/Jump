//
//  BlockFactory.swift
//  Jump
//
//  Created by debavlad on 21.01.2020.
//  Copyright © 2020 Vladislav Deba. All rights reserved.
//

import Foundation
import SpriteKit

class BlockFactory {
	var y, width: CGFloat
	let data: Dictionary<BlockType, (Int, CGFloat)>
	let distance: ClosedRange<CGFloat>
	
	let foodFactory: FoodFactory
	let coinFactory: CoinFactory
	let potionFactory: PotionFactory
	let coinChance, potionChance: CGFloat
	var foodCounter: Int
	
	let stage: Stage
	var set: [Block]
	let world: SKNode
	
	init(_ world: SKNode) {
		y = UIScreen.main.bounds.height
		width = UIScreen.main.bounds.width - 100
		data = [
			.Dirt : (76, 3),
			.Sand : (80, 4),
			.Wooden : (84, 5),
			.Stone : (88, 6)
		]
		distance = 125...200
		foodFactory = FoodFactory()
		coinFactory = CoinFactory()
		potionFactory = PotionFactory()
		coinChance = 0.5
		potionChance = 0.2
		foodCounter = 0
		
		stage = Stage()
		set = []
		self.world = world
	}
	
	func can(_ playerY: CGFloat) -> Bool {
		return y + distance.lowerBound < playerY + UIScreen.main.bounds.height
	}
	
	func produce() {
		let type = stage.blocks.randomElement()!
		let block = Block(type, data[type]!)
		addRandomLoot(to: block)
		block.node.position = CGPoint(x: CGFloat.random(in: -width...width), y: y)
		y += CGFloat.random(in: distance) + (type == .Dirt ? 150 : 0)
		switch type {
			case .Dirt: block.vertMove(150)
			case .Wooden, .Stone: block.horMove(width)
			default: break
		}
		world.addChild(block.node)
		set.append(block)
	}
	
	func find(_ node: SKNode) -> Block {
		return set.first { (block) -> Bool in
			block.node == node
		}!
	}
	
	func findItem(_ node: SKNode) -> Item? {
		guard let parent = node.parent else { return nil }
		for item in find(parent).items! {
			if item.node == node {
				return item
			}
		}
		return nil
	}
	
	func dispose(_ minY: CGFloat) {
		guard let b = set.first else { return }
		let top = b.node.frame.maxY + (b.isEmpty() ? 0 : b.items!.first!.node.frame.maxY)
		if top < minY {
			set.removeFirst()
			b.node.removeFromParent()
		}
	}
	
	private func addRandomLoot(to block: Block) {
		// keep order: coin-potion-food
		// to calculate top of block frame truly
		
		if random(coinChance) {
			block.addItem(coinFactory.getInstance())
		}
		if random(potionChance) {
			block.addItem(potionFactory.getInstance())
		}
		if foodCounter >= stage.foodFreq {
			foodCounter = 0
			block.addItem(foodFactory.getInstance())
		} else {
			foodCounter += 1
		}
	}
	
	private func random(_ chance: CGFloat) -> Bool {
		let x = CGFloat.random(in: 0...1)
		return x <= chance
	}
}
