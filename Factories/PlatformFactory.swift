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
	var maxY: CGFloat
	private let distance: ClosedRange<CGFloat>
	private(set) var platforms: [Platform]
	var birds: Set<Bird>
	private let data: [PlatformType : (texture: SKTexture, power: Int, damage: Int)]
	private let itemFactory: ItemFactory
	private(set) var stage: Stage
	private let parent: SKNode!
	private var jumpsAmount = 0
	static var foodFrequency = 3
	private let width, height: CGFloat
	private let birdAnim: SKAction
    
    
	init(_ parent: SKNode, _ startY: CGFloat, _ distance: ClosedRange<CGFloat>) {
		width = UIScreen.main.bounds.width - 100
		height = UIScreen.main.bounds.height + 50
		self.maxY = startY
		self.distance = distance
		self.parent = parent
		platforms = []
		birds = Set<Bird>()
		stage = Stage()
		itemFactory = ItemFactory()
		
		data = [
			PlatformType.dirt : (SKTexture(imageNamed: "dirt-platform").px(), 73, 3),
			PlatformType.sand : (SKTexture(imageNamed: "sand-platform").px(), 78, 4),
			PlatformType.wood : (SKTexture(imageNamed: "wooden-platform").px(), 83, 5),
			PlatformType.stone : (SKTexture(imageNamed: "stone-platform").px(), 88, 6)
		]
		
		birdAnim = SKAction.animate(with: [SKTexture(imageNamed: "bird0").px(),
		 SKTexture(imageNamed: "bird1").px(), SKTexture(imageNamed: "bird2").px()], timePerFrame: 0.1)
	}
	
	func create(_ playerY: CGFloat) {
		if !(maxY + distance.lowerBound < playerY + height) { return }
		let type = stage.platforms.randomElement()!
		let pos = CGPoint(x: CGFloat.random(in: -width...width), y: maxY + CGFloat.random(in: distance))
		let platform = Platform(type, data[type]!)
		platform.node.position = pos
		let birdY = (pos.y + maxY)/2
		maxY = type == .dirt ? pos.y + 150 : pos.y
		
		if jumpsAmount >= PlatformFactory.foodFrequency {
			platform.addItem(itemFactory.randomFood())
			jumpsAmount = 0
		} else { jumpsAmount += 1 }
		if random(0.2) { platform.addItem(itemFactory.randomCoin(stage.coins)) }
		if random(0.1) { platform.addItem(Potion()) }
		if !platform.hasItems() && random(0.075) { platform.addItem(Trampoline()) }
		if random(0.1) {
			let b = Bird(width, birdY)
			b.node.run(SKAction.repeatForever(birdAnim))
			parent.addChild(b.node)
			birds.insert(b)
		}
		
		switch type {
			case .dirt:
				platform.moveY(150)
			case .sand: break
			case .wood, .stone:
				platform.moveX(width)
		}
		parent.addChild(platform.node)
		platforms.append(platform)
	}
    
	func removeLowerThan(_ y: CGFloat) {
		guard let p = platforms.first else { return }
		let top = p.node.frame.maxY + (p.hasItems() ? p.items.first!.node.frame.maxY - 30 : 0)
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

enum PlatformType: Int {
	case dirt
	case sand
	case wood
	case stone
}
