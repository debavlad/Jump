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
	private let distance: ClosedRange<CGFloat>
	private(set) var platforms: [Platform]
	private(set) var items: Set<Item>
	private let data: [PlatformType : (texture: SKTexture, power: Int, damage: Int)]
	private var lastPlatformType = PlatformType.dirt
	private let parent: SKNode!
	private var jumpCounter = 0
	static var foodRegularJumps = 5
	
	private(set) var stage: Stage
	private let coinFactory: CoinFactory
	private let foodFactory: FoodFactory
	private let width, height: CGFloat
	
	private let samplePlatform: SKSpriteNode
    
    
	init(_ parent: SKNode, _ startY: CGFloat, _ distance: ClosedRange<CGFloat>) {
		width = UIScreen.main.bounds.width - 100
		height = UIScreen.main.bounds.height + 50
		self.highestY = startY
		self.distance = distance
		stage = Stage()
		coinFactory = CoinFactory()
		foodFactory = FoodFactory()
		platforms = []
		items = Set<Item>()
		self.parent = parent
		
		data = [
			PlatformType.dirt : (SKTexture(imageNamed: "dirt-platform").px(), 73, 3),
			PlatformType.sand : (SKTexture(imageNamed: "sand-platform").px(), 78, 4),
			PlatformType.wood : (SKTexture(imageNamed: "wooden-platform").px(), 83, 5),
			PlatformType.stone : (SKTexture(imageNamed: "stone-platform").px(), 88, 6)
		]
		
		samplePlatform = SKSpriteNode()
		samplePlatform.size = CGSize(width: 117, height: 45)
		samplePlatform.name = "platform"
		samplePlatform.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 83.5, height: 1), center: CGPoint(x: 0, y: 20))
		samplePlatform.physicsBody?.restitution = CGFloat(0.2)
		samplePlatform.physicsBody?.friction = 0
		samplePlatform.physicsBody?.mass = 10
		samplePlatform.physicsBody?.linearDamping = 0
		samplePlatform.physicsBody?.angularDamping = 0
		samplePlatform.physicsBody?.contactTestBitMask = Categories.player
		samplePlatform.physicsBody?.categoryBitMask = Categories.platform
		samplePlatform.physicsBody?.collisionBitMask = Categories.coin | Categories.food
		samplePlatform.physicsBody?.isDynamic = false
	}
    
	func create(_ playerY: CGFloat) {
		if !(highestY + distance.lowerBound < playerY + height) { return }
		let type = stage.availablePlatforms.randomElement()!
		lastPlatformType = type
		let pos = CGPoint(x: CGFloat.random(in: -width...width), y: highestY + CGFloat.random(in: distance))
		let platform = construct(type, pos)
		highestY = type == .dirt ? pos.y + 150 : pos.y
		
		if (random(0.2)) {
			let coin = coinFactory.random(stage.availableCoins)
			platform.addItem(coin)
			items.insert(coin)
		}
		if jumpCounter >= PlatformFactory.foodRegularJumps {
			let food = foodFactory.getRandomFood()
			platform.addItem(food)
			items.insert(food)
			jumpCounter = 0
		} else { jumpCounter += 1 }
		
		switch type {
			case .dirt:
				platform.moveByY(150)
			case .sand: break
			case .wood, .stone:
				platform.moveByX(width)
		}
		
		parent.addChild(platform.node)
		platforms.append(platform)
	}
    
	func clean() {
		platforms.forEach { (p) in p.node.removeFromParent() }
		platforms.removeAll()
	}
    
	func remove(_ minY: CGFloat) {
		if platforms.count <= 0 { return }
		let p = platforms.first!
		var top = p.node.frame.maxY
		top += p.hasItems() ? p.items.first!.node.frame.maxY - 30 : 0
		if top < minY {
			p.node.removeFromParent()
			platforms.removeFirst()
		}
	}
    
	func findItem(_ node: SKNode) -> Item {
		return items.first(where: { (i) -> Bool in i.node == node })!
	}
    
	func removeItem(_ item: Item, from platform: Platform) {
		items.remove(item)
		platform.removeItem(item)
	}
    
	func findPlatform(_ platform: SKNode) -> Platform {
		return platforms.first(where: { (p) -> Bool in p.node == platform })!
	}
    
	func lowestY() -> CGFloat? {
		return platforms.first?.node.position.y
	}
    
	private func construct(_ type: PlatformType, _ pos: CGPoint) -> Platform {
		let platform = Platform(samplePlatform, type, data[type]!)
		platform.node.position = pos
		return platform
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


class Stage {
	var current = 0
	var availablePlatforms: [PlatformType]
	var availableCoins: [Currency]
    
	init() {
		availablePlatforms = [.sand]
		availableCoins = [.wood]
	}
    
	func setStageLabels(btm: SKLabelNode, top: SKLabelNode) {
		btm.text = "\(current)"
		top.text = "\(current+1)"
		DispatchQueue.global(qos: .background).async {
				GSAudio.sharedInstance.playSound(soundFileName: "tada")
		}
	}
    
	func upgrade(_ stage: Int) {
		switch (stage) {
		case 1:
			current = 1
			availablePlatforms.append(.wood)
			availableCoins.append(.bronze)
			PlatformFactory.foodRegularJumps = 6
		case 2:
			current = 2
			availablePlatforms.append(.stone)
			PlatformFactory.foodRegularJumps = 7
		case 3:
			current = 3
			availableCoins.append(.golden)
		default: break
		}
	}
}
