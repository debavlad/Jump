//
//  Block.swift
//  Jump
//
//  Created by debavlad on 22.01.2020.
//  Copyright © 2020 Vladislav Deba. All rights reserved.
//

import Foundation
import SpriteKit

class Block: Hashable {
	let node: SKSpriteNode
	var items: [Item]?
	let type: BlockType
	let power: Int
	let damage: CGFloat
	
	init(_ type: BlockType, _ data: (Int, CGFloat)) {
		self.type = type
		node = SKSpriteNode(imageNamed: type.rawValue).blockOptions().px()
		items = nil
		power = data.0
		damage = data.1
	}
	
	func vertMove(_ dist: CGFloat) {
		let bottom = node.position.y, top = bottom + dist, speed = Double.random(in: 1.35...1.65)
		let up = SKAction.move(to: CGPoint(x: node.position.x, y: top), duration: speed)
		let down = SKAction.move(to: CGPoint(x: node.position.x, y: bottom), duration: speed)
		up.timingMode = .easeInEaseOut; down.timingMode = .easeInEaseOut
		node.run(SKAction.repeatForever(SKAction.sequence([up, down])))
	}
	
	func horMove(_ dist: CGFloat) {
		let speed = Double.random(in: 1.85...2.15)
		let right = SKAction.move(to: CGPoint(x: dist, y: node.position.y), duration: speed)
		let left = SKAction.move(to: CGPoint(x: -dist, y: node.position.y), duration: speed)
		right.timingMode = .easeInEaseOut; left.timingMode = .easeInEaseOut
		node.run(SKAction.repeatForever(SKAction.sequence(node.position.x > 0 ?
			[left, right] : [right, left])))
	}
	
	func isEmpty() -> Bool {
		return items == nil || items?.count == 0
	}
	
	func addItem(_ item: Item) {
		if items == nil {
			items = []
		}
		items!.append(item)
		node.addChild(item.node)
	}
	
	func removeItem(_ item: Item) {
		if let index = items?.firstIndex(of: item) {
			item.execute()
			items?.remove(at: index)
		}
	}
	
	func fall(_ contactX: CGFloat) {
		node.fall()
		node.physicsBody?.applyAngularImpulse(contactX > node.position.x ? -0.1 : 0.1)
		if isEmpty() { return }
		for item in items! {
			item.node.fall()
			item.node.physicsBody?.applyImpulse(CGVector(dx: 0, dy: -20))
		}
	}
	
	func hash(into hasher: inout Hasher) {
		hasher.combine(node)
	}
	
	static func == (lhs: Block, rhs: Block) -> Bool {
		return lhs.hashValue == rhs.hashValue
	}
}

enum BlockType: String, CaseIterable {
	case Dirt, Sand, Wooden, Stone
}
