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
	let data: Dictionary<BlockType, (Int, Int)>
	let itemFactory: ItemFactory
	var set: [Block]
	let world: SKNode
	
	init(_ world: SKNode, _ itemFactory: ItemFactory) {
		self.world = world
		self.itemFactory = itemFactory
		y = UIScreen.main.bounds.height
		width = UIScreen.main.bounds.width - 100
		data = [
			.Dirt : (76, 3),
			.Sand : (80, 4),
			.Wooden : (84, 5),
			.Stone : (88, 6)
		]
		set = []
	}
	
	func produce(_ amount: Int) {
		for _ in 0..<amount {
			let type = BlockType.allCases.randomElement()!
			let block = Block(type, data[type]!)
			addRandomLoot(to: block)
			block.node.position = CGPoint(x: CGFloat.random(in: -width...width), y: y)
			y += CGFloat.random(in: 125...200) + (type == .Dirt ? 150 : 0)
			switch type {
				case .Dirt: block.vertMove(150)
				case .Wooden, .Stone: block.horMove(width)
				default: break
			}
			world.addChild(block.node)
			set.append(block)
		}
	}
	
	func find(_ node: SKNode) -> Block {
		return set.first { (block) -> Bool in
			block.node == node
		}!
	}
	
	func findItem(_ node: SKNode) -> Item? {
		for block in set.filter({ (b) -> Bool in return !b.isEmpty() }) {
			if let item = block.items?.first(where: { (i) -> Bool in i.node == node }) {
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
		// TO-DO: let coinChance, potChance, foodChance
		
		if Bool.random() {
			let coin = itemFactory.getCoin()
			block.addItem(coin)
		}
		if Bool.random() {
			let pot = itemFactory.getPotion()
			block.addItem(pot)
		}
		let food = itemFactory.getFood()
		block.addItem(food)
	}
	
	private func random(_ chance: Double) -> Bool {
		let x = Double.random(in: 0...1)
		return x <= chance
	}
}
