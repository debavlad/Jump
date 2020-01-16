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
	private var health, maxHp: Int!
	private(set) var isAlive = true
	
	private let green, yellow, red: SKTexture!
	private let hpBorder, hpLine: SKSpriteNode!
	private let maxLineWidth: CGFloat
	private(set) var currentAnim, jumpAnim, fallAnim, landAnim, sitAnim: SKAction!
	
	
	init(_ node: SKNode) {
		self.node = node as! SKSpriteNode
		green = SKTexture(imageNamed: "hp-green")
		yellow = SKTexture(imageNamed: "hp-yellow")
		red = SKTexture(imageNamed: "hp-red")
		hpBorder = node.children.first! as? SKSpriteNode
		hpLine = hpBorder.children.first! as? SKSpriteNode
		maxLineWidth = hpLine.size.width
		setNodes()
	}
    
	func push(power: Int, nullify: Bool) {
		runAnim(jumpAnim)
		if nullify { node.physicsBody!.velocity = CGVector() }
		node.physicsBody!.applyImpulse(CGVector(dx: 0, dy: power))
	}
	
	func turn(left: Bool) {
		node.xScale = left ? -1 : 1
		hpBorder.xScale = node.xScale
	}
	
	func revive() {
		isAlive = true
		editHp(maxHp)
	}
	
	func editHp(_ amount: Int) {
		let tmp = health + amount
		if tmp <= 0 {
			health = 0
			isAlive = false
			hpLine.size.width = 0
		} else if tmp >= maxHp {
			health = maxHp
			hpLine.size.width = maxLineWidth
		} else {
			health = tmp
			hpLine.size.width = maxLineWidth/CGFloat(maxHp)*CGFloat(tmp)
		}
		
		if tmp <= 25 { hpLine.texture = red }
		else if tmp <= 50 { hpLine.texture = yellow }
		else if tmp <= 100 { hpLine.texture = green }
	}
    
	func isFalling() -> Bool {
		return node.physicsBody!.velocity.dy < 0
	}
    
	func runAnim(_ anim: SKAction) {
		node.run(anim)
		currentAnim = anim
	}
    
	private func setNodes() {
		// Physics
		node.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 50, height: 20), center: CGPoint(x: -5, y: -50))
		node.physicsBody?.collisionBitMask = Categories.ground
		node.physicsBody?.categoryBitMask = Categories.player
		node.physicsBody?.contactTestBitMask = Categories.coin | Categories.food | Categories.platform
		node.physicsBody?.allowsRotation = false
		node.physicsBody?.friction = 0
		node.physicsBody?.restitution = GameScene.restarted ? 0.4 : 0
		node.physicsBody?.linearDamping = 0
		node.physicsBody?.angularDamping = 0
		
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
		
		for i in 4...5 {
			textures.append(SKTexture(imageNamed: "\(skinName)-jump\(i)").px())
		}
		fallAnim = SKAction.animate(with: textures, timePerFrame: 0.11)
		textures.removeAll(keepingCapacity: true)
		
		for i in 6...8 {
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
