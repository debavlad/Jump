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
	var set: Set<Block>
	let world: SKNode
	
	init(_ world: SKNode, _ itemFactory: ItemFactory) {
		self.world = world
		self.itemFactory = itemFactory
		y = UIScreen.main.bounds.height
		width = UIScreen.main.bounds.width - 100
		data = [
			.Dirt : (73, 3),
			.Sand : (78, 4),
			.Wooden : (83, 5),
			.Stone : (88, 6)
		]
		set = Set<Block>()
	}
	
	func produce(_ amount: Int) {
		for _ in 0..<amount {
			let type = BlockType.allCases.randomElement()!
			let block = Block(type, data[type]!)
			addRandomLoot(to: block)
			block.node.position = CGPoint(x: CGFloat.random(in: -width...width), y: y)
			y += CGFloat.random(in: 125...200)
			world.addChild(block.node)
			set.insert(block)
		}
	}
	
	func find(_ node: SKNode) -> Block {
		return set.first { (block) -> Bool in
			block.node == node
		}!
	}
	
	private func addRandomLoot(to block: Block) {
		let food = itemFactory.getFood()
		block.addItem(food)
		if Bool.random() {
			let coin = itemFactory.getCoin()
			block.addItem(coin)
		}
		if Bool.random() {
			let pot = itemFactory.getPotion()
			block.addItem(pot)
		}
	}
}
