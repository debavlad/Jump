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
	
	private let colors: [UIColor]
	private var colorIndex = 0
	
	init(_ target: SKSpriteNode, _ colors: [UIColor]) {
		self.target = target
		self.colors = colors
		
		particle = SKSpriteNode(imageNamed: "particle")
		particle.zPosition = 5
		particle.colorBlendFactor = 1
		
		anim = SKAction.group([SKAction.fadeOut(withDuration: 1),
													 SKAction.scale(to: 0.7, duration: 1.25)])
		anim.timingMode = .easeIn
	}
	
	func create(in parent: SKNode, _ scale: CGFloat = 20) {
		let copy = particle.copy() as! SKSpriteNode
		copy.position = target.position
		copy.zRotation = CGFloat.random(in: -20...20)
		copy.setScale(scale)
		copy.alpha = 1.0
		
		colorIndex = colorIndex < colors.count - 1 ? colorIndex + 1 : 0
		copy.color = colors[colorIndex]
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
