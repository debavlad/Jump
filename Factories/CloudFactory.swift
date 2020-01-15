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
	var distance, maxY, speed: CGFloat
	private let width, height: CGFloat
	private var set: Set<SKSpriteNode>!
	private var textures: [SKTexture]
	
	
	init(_ distance: CGFloat, _ maxY: CGFloat) {
		self.distance = distance
		self.maxY = maxY
		speed = distance <= 500 ? 1 : 0.5
		width = UIScreen.main.bounds.width
		height = UIScreen.main.bounds.height + 50
		set = Set<SKSpriteNode>()
		textures = [
			SKTexture(imageNamed: "cloud-0").px(),
			SKTexture(imageNamed: "cloud-1").px(),
			SKTexture(imageNamed: "cloud-2").px(),
			SKTexture(imageNamed: "cloud-3").px()
		]
	}
	
	func canBuild(_ playerY: CGFloat, _ started: Bool) -> Bool {
		return maxY + distance < (started ? playerY + height : height)
	}
	
	func create(_ pos: CGPoint? = nil) -> SKSpriteNode {
		let cloud = SKSpriteNode(texture: textures.randomElement()!)
		cloud.zPosition = distance <= 500 ? -5 : 15
		cloud.setScale(CGFloat.random(in: distance <= 500 ? 12...16 : 22...28))
		cloud.alpha = distance <= 500 ? 1 : 0.5
		if Bool.random() { cloud.xScale *= -1 }
		
		if let p = pos {
			cloud.position = p
			cloud.position.x -= cloud.frame.width/2
		} else {
			let tmp = CGPoint(x: CGFloat.random(in: -width...width), y: maxY + distance)
			cloud.position = tmp
			maxY = tmp.y
		}
		set.insert(cloud)
		return cloud
	}
	
	func move() {
		// TO-DO: Make clouds move via SKAction
		for c in set {
			if c.frame.maxY > bounds.minY {
				c.position.x += speed
			}
		}
	}
	
	func dispose() {
		set.forEach { (c) in
			if c.position.x > 0 &&
				set.filter({ (n) -> Bool in return n.position.y == c.position.y}).count <= 1 {
				let cloud = create(CGPoint(x: bounds.minX, y: c.position.y))
				c.parent!.addChild(cloud)
				set.insert(cloud)
			}
			if c.frame.maxY < bounds.minY - height*2 || c.frame.minX > bounds.maxX {
				c.removeFromParent()
				set.remove(c)
			}
		}
	}
}
