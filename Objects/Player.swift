//
//  Player.swift
//  Jump
//
//  Created by Vladislav Deba on 8/15/19.
//  Copyright © 2019 Vladislav Deba. All rights reserved.
//

import Foundation
import SpriteKit

class Player {
	let node: SKSpriteNode
	var health, maxHp: CGFloat!
	private(set) var isAlive = true
	
	private let green, yellow, red: SKTexture!
	private let hpLine: SKSpriteNode!
	private let maxLineWidth: CGFloat
	private(set) var anim, jumpAnim, fallAnim, landAnim, sitAnim: SKAction!
	
	
	init(_ node: SKNode) {
		self.node = node as! SKSpriteNode
		green = SKTexture(imageNamed: "hp-green")
		yellow = SKTexture(imageNamed: "hp-yellow")
		red = SKTexture(imageNamed: "hp-red")
		hpLine = node.children.first! as? SKSpriteNode
		maxLineWidth = hpLine.size.width
		setNodes()
	}
    
	func push(_ power: CGFloat, nullify: Bool) {
		animate(jumpAnim)
		if nullify { node.physicsBody!.velocity = CGVector() }
		node.physicsBody!.applyImpulse(CGVector(dx: 0, dy: power))
	}
	
	func turn(left: Bool) {
		node.xScale = left ? -1 : 1
		hpLine.xScale = left ? -1 : 1
//		hpLine.xScale = node.xScale
	}
	
	func revive() {
		isAlive = true
		adjustHealth(maxHp)
	}
	
	func adjustHealth(_ points: CGFloat) {
		let val = health + points
		if val > 0 && val < maxHp {
			health = val
			hpLine.size.width = maxLineWidth / maxHp * val
		} else if val >= maxHp {
			health = maxHp
			hpLine.size.width = maxLineWidth
		} else if val <= 0 {
			health = 0
			isAlive = false
			hpLine.size.width = 0
		}
	}
    
	func isFalling() -> Bool {
		return node.physicsBody!.velocity.dy < 0
	}
    
	func animate(_ anim: SKAction) {
		node.run(anim)
		self.anim = anim
	}
    
	private func setNodes() {
		// Physics
		node.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 50, height: 20), center: CGPoint(x: -5, y: -50))
		node.physicsBody?.collisionBitMask = Bit.ground
		node.physicsBody?.categoryBitMask = Bit.player
		node.physicsBody?.contactTestBitMask = Bit.potion | Bit.coin | Bit.food | Bit.platform
		node.physicsBody?.allowsRotation = false
		node.physicsBody?.friction = 0
		node.physicsBody?.restitution = GameScene.restarted ? 0.4 : 0
		node.physicsBody?.linearDamping = 0
		node.physicsBody?.angularDamping = 0
		
		let tmp = SKSpriteNode(imageNamed: "light").px()
		tmp.setScale(5.5)
		let up = SKAction.scale(to: 5.6, duration: 0.15)
		let down = SKAction.scale(to: 5.5, duration: 0.15)
		up.timingMode = .easeOut; down.timingMode = .easeOut
		tmp.run(SKAction.repeatForever(SKAction.sequence([up, down])))
//		var t = [SKTexture]()
//		for i in 1...2 { t.append(SKTexture(imageNamed: "lighting\(i)").px()) }
//		let anim = SKAction.animate(with: t, timePerFrame: 0.12)
//		tmp.run(SKAction.repeatForever(anim))
		node.addChild(tmp)
		
		// Animations
		let skinName = "\(Skins[GameScene.skinIndex].name)"
		maxHp = skinName == "zombie" ? 150 : 100
		health = maxHp
		
		var textures = [SKTexture]()
		for i in 0...3 {
			textures.append(SKTexture(imageNamed: "\(skinName)-jump\(i)").px())
		}
		jumpAnim = SKAction.animate(with: textures, timePerFrame: 0.11)
		textures.removeAll(keepingCapacity: true)
		
		for i in 4...4 {
			textures.append(SKTexture(imageNamed: "\(skinName)-jump\(i)").px())
		}
		fallAnim = SKAction.animate(with: textures, timePerFrame: 0.11)
		textures.removeAll(keepingCapacity: true)
		
		for i in 5...6 {
			textures.append(SKTexture(imageNamed: "\(skinName)-jump\(i)").px())
		}
		landAnim = SKAction.animate(with: textures, timePerFrame: 0.06)
		textures.removeAll(keepingCapacity: true)
		
		for i in 0...7 {
			textures.append(SKTexture(imageNamed: "\(skinName)-sit\(i)").px())
		}
		sitAnim = SKAction.animate(with: textures, timePerFrame: 0.15)
		textures.removeAll()
		
		node.run(SKAction.repeatForever(sitAnim))
	}
}
