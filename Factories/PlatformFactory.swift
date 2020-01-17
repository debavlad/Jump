//
//  PlatformFactory.swift
//  Jump
//
//  Created by Vladislav Deba on 7/30/19.
//  Copyright © 2019 Vladislav Deba. All rights reserved.
//

import Foundation
import SpriteKit

class PlatformFactory {
	var highestY: CGFloat
	private let w, h: CGFloat
	private let dist: ClosedRange<CGFloat>
	private(set) var platforms = [Platform]()
	private let data: [PlatformType : (power: Int, damage: Int)]
	private let items = ItemFactory()
	private(set) var stage = Stage()
	public var birds = Set<Bird>()
	private let parent: SKNode
	
	private var jumpsAmount = 0
	private let birdAnim: SKAction
    
	init(_ node: SKNode, _ y: CGFloat, _ dist: ClosedRange<CGFloat>) {
		highestY = y
		self.dist = dist
		parent = node
		data = [
			PlatformType.dirt : (73, 3),
			PlatformType.sand : (78, 4),
			PlatformType.wooden : (83, 5),
			PlatformType.stone : (88, 6)
		]
		w = UIScreen.main.bounds.width - 100
		h = UIScreen.main.bounds.height + 50
		//
		birdAnim = SKAction.animate(with: [SKTexture(imageNamed: "bird0").px(),
		 SKTexture(imageNamed: "bird1").px(), SKTexture(imageNamed: "bird2").px()],
			timePerFrame: 0.1)
	}
	
	func create(_ playerY: CGFloat) {
		if !(highestY + dist.lowerBound < playerY + h) { return }
		let t = stage.platforms.randomElement()!
		let pos = CGPoint(x: CGFloat.random(in: -w...w), y: highestY + CGFloat.random(in: dist))
		let p = Platform(t, data[t]!)
		p.node.position = pos
		let birdY = (pos.y + highestY)/2
		highestY = (t == .dirt ? pos.y + 150 : pos.y)
		
		if jumpsAmount >= stage.foodFreq {
			p.addItem(items.randomFood())
			jumpsAmount = 0
		} else { jumpsAmount += 1 }
		if random(0.2) { p.addItem(items.randomCoin(stage.coins)) }
		if random(0.1) { p.addItem(items.randomPotion())}
		if !p.hasItems() && random(0.075) { p.addItem(Trampoline()) }
		if random(0.1) {
			let b = Bird(w, birdY)
			b.node.run(SKAction.repeatForever(birdAnim))
			parent.addChild(b.node)
			birds.insert(b)
		}
		
		switch (t) {
			case .dirt: p.moveY(150)
			case .wooden, .stone: p.moveX(w)
			default: break
		}
		parent.addChild(p.node)
		platforms.append(p)
	}
    
	func removeLowerThan(_ y: CGFloat) {
		guard let p = platforms.first else { return }
		let top = p.node.position.y + (p.hasItems() ? p.items.first!.node.frame.maxY : 0)
		if top < y {
			p.node.removeFromParent()
			platforms.removeFirst()
		}
	}
    
	func getItem(_ node: SKNode) -> Item? {
		for platform in platforms {
			if !platform.hasItems() { continue }
			if let item = platform.items.first(where: { (i) -> Bool in i.node == node }) {
				return item
			}
		}
		return nil
	}
    
	func removeItem(_ item: Item, from platform: Platform) {
		platform.items.remove(item)
		item.node.removeFromParent()
	}
    
	func getPlatform(_ node: SKNode) -> Platform {
		return platforms.first(where: { (p) -> Bool in p.node == node })!
	}
    
	private func random(_ chance: Double) -> Bool {
		let x = Double.random(in: 0...1)
		return x <= chance
	}
}

enum PlatformType: String {
	case dirt, sand, wooden, stone
}
