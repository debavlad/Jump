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
	var health: CGFloat
	private(set) var alive: Bool
	var falling: Bool {
		get { return node.physicsBody!.velocity.dy < 0 }
	}
	
	private let hpTexture: SKTexture
	private let hpLine: SKSpriteNode
	private let maxLineWidth: CGFloat
	private(set) var anim, jumpAnim, fallAnim, landAnim, sitAnim: SKAction!
	private(set) var lighting: SKSpriteNode!
	
	
	init(_ node: SKNode) {
		self.node = node as! SKSpriteNode
		health = 100
		alive = true
		hpTexture = SKTexture(imageNamed: "hp").px()
		hpLine = node.children.first! as! SKSpriteNode
		maxLineWidth = hpLine.size.width
		setNodes()
	}
    
	func push(_ power: Int, nullify: Bool) {
		animate(jumpAnim)
		if nullify { node.physicsBody!.velocity = CGVector() }
		node.physicsBody!.applyImpulse(CGVector(dx: 0, dy: power))
	}
	
	func turn(left: Bool) {
		node.xScale = left ? -1 : 1
		hpLine.xScale = left ? -1 : 1
	}
	
	func revive() {
		alive = true
		adjustHealth(100)
	}
	
	func adjustHealth(_ points: CGFloat) {
		let value = health + points
		if value > 0 && value < 100 {
			health = value
		} else if value >= 100 {
			health = 100
		} else if value <= 0 {
			health = 0
			alive = false
		}
		hpLine.size.width = maxLineWidth/100 * health
	}
    
	func animate(_ anim: SKAction) {
		node.run(anim)
		self.anim = anim
	}
    
	private func setNodes() {
		node.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 50, height: 20), center: CGPoint(x: -5, y: -50))
		node.physicsBody?.collisionBitMask = Bit.ground
		node.physicsBody?.categoryBitMask = Bit.player
		node.physicsBody?.contactTestBitMask = Bit.item | Bit.platform
		node.physicsBody?.allowsRotation = false
		node.physicsBody?.friction = 0
		node.physicsBody?.restitution = GameScene.restarted ? 0.4 : 0
		node.physicsBody?.linearDamping = 0
		node.physicsBody?.angularDamping = 0
		
		lighting = SKSpriteNode(imageNamed: "light").px()
		lighting.setScale(5.5)
		let up = SKAction.scale(to: 5.6, duration: 0.15)
		let down = SKAction.scale(to: 5.5, duration: 0.15)
		up.timingMode = .easeOut; down.timingMode = .easeOut
		lighting.run(SKAction.repeatForever(SKAction.sequence([up, down])))
		node.addChild(lighting)
		
		// Animations
		var textures = [SKTexture]()
		for i in 0...3 { textures.append(SKTexture(imageNamed: "jump\(i)").px()) }
		jumpAnim = SKAction.animate(with: textures, timePerFrame: 0.11)
		textures.removeAll(keepingCapacity: true)
		
		for i in 4...4 { textures.append(SKTexture(imageNamed: "jump\(i)").px()) }
		fallAnim = SKAction.animate(with: textures, timePerFrame: 0.11)
		textures.removeAll(keepingCapacity: true)
		
		for i in 0...7 { textures.append(SKTexture(imageNamed: "sit\(i)").px()) }
		sitAnim = SKAction.animate(with: textures, timePerFrame: 0.15)
		textures.removeAll()
		
		node.run(SKAction.repeatForever(sitAnim))
	}
}
