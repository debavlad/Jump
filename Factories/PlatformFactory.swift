//
//  PlatformFactory.swift
//  Jump
//
//  Created by Vladislav Deba on 7/30/19.
//  Copyright © 2019 Vladislav Deba. All rights reserved.
//

import Foundation
import SpriteKit

//class PlatformFactory {
//	var highestY: CGFloat
//	private let w, h: CGFloat
//	private let dist: ClosedRange<CGFloat>
//	private(set) var platforms = [Platform]()
//	private let data: [PlatformType : (power: Int, damage: Int)]
//	private let items = ItemFactory()
//	private(set) var stage = Stage()
//	public var birds = Set<Bird>()
//	private let parent: SKNode
//
//	private var jumpsAmount = 0
//	private let birdAnim: SKAction
//
//	init(_ node: SKNode, _ y: CGFloat, _ dist: ClosedRange<CGFloat>) {
//		highestY = y
//		self.dist = dist
//		parent = node
//		data = [
//			PlatformType.Dirt : (73, 3),
//			PlatformType.Sand : (78, 4),
//			PlatformType.Wooden : (83, 5),
//			PlatformType.Stone : (88, 6)
//		]
//		w = UIScreen.main.bounds.width - 100
//		h = UIScreen.main.bounds.height + 50
//		//
//		birdAnim = SKAction.animate(with: [SKTexture(imageNamed: "bird0").px(),
//		 SKTexture(imageNamed: "bird1").px(), SKTexture(imageNamed: "bird2").px()],
//			timePerFrame: 0.1)
//	}
//
//	func create(_ playerY: CGFloat) {
//		if !(highestY + dist.lowerBound < playerY + h) { return }
//		let t = stage.blocks.randomElement()!
//		let pos = CGPoint(x: CGFloat.random(in: -w...w), y: highestY + CGFloat.random(in: dist))
//		let p = Platform(t, data[t]!)
//		p.node.position = pos
//		let birdY = (pos.y + highestY)/2
//		highestY = (t == .Dirt ? pos.y + 150 : pos.y)
//
//		if jumpsAmount >= stage.foodFreq {
//			p.addItem(items.getFood())
//			jumpsAmount = 0
//		} else { jumpsAmount += 1 }
////		if random(0.2) { p.addItem(items.randomCoin(stage.coins)) }
//		if random(0.1) { p.addItem(items.getPotion())}
////		if !p.hasItems() && random(0.075) { p.addItem(Trampoline()) }
//		if random(0.1) {
//			let b = Bird(w, birdY)
//			b.node.run(SKAction.repeatForever(birdAnim))
//			parent.addChild(b.node)
//			birds.insert(b)
//		}
//
//		switch (t) {
//			case .Dirt: p.moveY(150)
//			case .Wooden, .Stone: p.moveX(w)
//			default: break
//		}
//		parent.addChild(p.node)
//		platforms.append(p)
//	}
//}
