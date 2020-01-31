//
//  Trail.swift
//  Jump
//
//  Created by debavlad on 8/26/19.
//  Copyright © 2019 Vladislav Deba. All rights reserved.
//

import Foundation
import SpriteKit

class Trail {
	private let target: SKSpriteNode
	private var particle: SKSpriteNode!
	private let anim: SKAction
	
	init(_ target: SKSpriteNode, _ color: UIColor) {
		self.target = target
		
		particle = SKSpriteNode(imageNamed: "particle")
		particle.zPosition = 5
		particle.colorBlendFactor = 1
		particle.color = color
		
		anim = SKAction.group([SKAction.fadeOut(withDuration: 0.8),
													 SKAction.scale(to: 0.7, duration: 1)])
		anim.timingMode = .easeIn
	}
	
	func create(in parent: SKNode, _ scale: CGFloat = 20) {
		let copy = particle.copy() as! SKSpriteNode
		copy.position = target.position
		copy.zRotation = CGFloat.random(in: -20...20)
		copy.setScale(scale)
		copy.alpha = 1.0
		particle = copy
		add(copy, to: parent)
	}
	
	private func add(_ particle: SKSpriteNode, to parent: SKNode) {
		let dispose = SKAction.run { particle.removeFromParent() }
		parent.addChild(particle)
		particle.run(SKAction.sequence([anim, dispose]))
	}
	
	func distance() -> CGFloat {
		let xDist = target.position.x - particle.position.x
		let yDist = target.position.y - particle.position.y
		let dist = sqrt((xDist * xDist) + (yDist * yDist))
		return dist
	}
}
