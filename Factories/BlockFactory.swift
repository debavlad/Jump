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
	var y, width, height: CGFloat
	let distance: ClosedRange<CGFloat>
	let data: Dictionary<BlockType, (Int, CGFloat)>
	let coinChance: CGFloat
	var foodCounter: Int
	let world: SKNode
	var array: [Block]
	
	init(_ world: SKNode) {
		distance = 125...200
		y = UIScreen.main.bounds.height
		width = UIScreen.main.bounds.width - 100
		height = UIScreen.main.bounds.height + distance.lowerBound
		data = [
			.Dirt : (76, 3),
			.Sand : (80, 4),
			.Wooden : (84, 5),
			.Stone : (88, 6)
		]
		coinChance = 0.5
		foodCounter = 0
		
		array = []
		self.world = world
	}
	
	func can(_ playerY: CGFloat) -> Bool {
		return y + distance.lowerBound < playerY + height
	}
	
	func produce() {
		let type = Stage.shared.blocks.randomElement()!
		let block = Block(type, data[type]!)
		block.node.position = CGPoint(x: CGFloat.random(in: -width...width), y: y)
		y += CGFloat.random(in: distance) + (type == .Dirt ? 150 : 0)
		addRandomLoot(to: block)
		switch type {
			case .Dirt: block.vertMove(150)
			case .Wooden, .Stone: block.horMove(width)
			default: break
		}
		world.addChild(block.node)
		array.append(block)
	}
	
	func find(_ node: SKNode) -> Block {
		return array.first(where: { $0.node == node })!
	}
	
	func findItem(_ node: SKNode) -> Item? {
		guard let p = node.parent, let items = find(p).items else { return nil }
		return items.first(where: { $0.node == node })
	}
	
	func dispose(_ minY: CGFloat) {
		guard let b = array.first else { return }
		if b.node.position.y < minY {
			array.removeFirst()
			b.node.removeFromParent()
		}
	}
	
	private func addRandomLoot(to block: Block) {
		if foodCounter >= Stage.shared.foodFreq {
			foodCounter = 0
			block.addItem(FoodFactory.shared.produce())
		} else {
			foodCounter += 1
			if random(coinChance) {
				block.addItem(CoinFactory.shared.produce())
			}
		}
	}
	
	private func random(_ chance: CGFloat) -> Bool {
		let x = CGFloat.random(in: 0...1)
		return x <= chance
	}
}
