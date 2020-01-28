//
//  CloudFactory.swift
//  Jump
//
//  Created by Vladislav Deba on 7/31/19.
//  Copyright © 2019 Vladislav Deba. All rights reserved.
//

import Foundation
import SpriteKit

class CloudFactory {
	var dist, highestY, speed: CGFloat
	private let w, h: CGFloat
	private var set = Set<SKSpriteNode>()
	private var textures = [SKTexture]()
	
	
	init(_ dist: CGFloat, _ y: CGFloat) {
		self.dist = dist
		highestY = y
		speed = dist <= 500 ? 1 : 0.5
		w = UIScreen.main.bounds.width
		h = UIScreen.main.bounds.height + 50
		textures.append(contentsOf: [
			SKTexture(imageNamed: "cloud-0").px(),
			SKTexture(imageNamed: "cloud-1").px(),
			SKTexture(imageNamed: "cloud-2").px(),
			SKTexture(imageNamed: "cloud-3").px()
		])
	}
	
	func canSpawn(_ playerY: CGFloat, _ started: Bool) -> Bool {
		return highestY + dist < (started ? playerY + h : h)
	}
	
	func create(_ pos: CGPoint?=nil) -> SKSpriteNode {
		let c = SKSpriteNode(texture: textures.randomElement()!)
		if (dist <= 500) { c.zPosition = -5; c.setScale(CGFloat.random(in: 12...16)); c.alpha = 1 }
		else { c.zPosition = 15; c.setScale(CGFloat.random(in: 22...28)); c.alpha = 0.5 }
		if Bool.random() { c.xScale *= -1 }
		
		if let p = pos {
			c.position = p
			c.position.x -= c.frame.width/2
		} else {
			let rand = CGPoint(x: CGFloat.random(in: -w...w), y: highestY + dist)
			c.position = rand
			highestY = rand.y
		}
//		c.run(SKAction.moveTo(x: w + c.frame.width, duration: dist <= 500 ? 15 : 25))
		set.insert(c)
		return c
	}
	
//	func move() {
//		// TO-DO: Make clouds move via SKAction
//		for c in set {
//			if c.frame.maxY > bounds.minY {
//				c.position.x += speed
//			}
//		}
//	}
	
	func dispose() {
		set.forEach { (c) in
			if c.position.x > 0 &&
				set.filter({ (n) -> Bool in return n.position.y == c.position.y}).count <= 1 {
				let cloud = create(CGPoint(x: bounds.minX, y: c.position.y))
				c.parent!.addChild(cloud)
				set.insert(cloud)
			}
			if c.frame.maxY < bounds.minY - h*2 || c.frame.minX > bounds.maxX {
				c.removeFromParent()
				set.remove(c)
			}
		}
	}
}
