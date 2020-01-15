//
//  Message.swift
//  Jump
//
//  Created by debavlad on 8/27/19.
//  Copyright © 2019 Vladislav Deba. All rights reserved.
//

import Foundation
import SpriteKit

class Tip {
	let node: SKSpriteNode
	let label: SKLabelNode
	
	init(_ text: String, _ position: CGPoint, _ flipped: Bool = false) {
		label = SKLabelNode(fontNamed: "pixelFJ8pt1")
		label.text = text
		label.fontColor = .black
		label.fontSize = 34
		label.zPosition = 2
		
		// Gathering parts into one node
		let left = SKSpriteNode(imageNamed: "msg-left").px()
		let mid = SKSpriteNode(imageNamed: "msg-mid").px()
		let bottom = SKSpriteNode(imageNamed: "msg-btm").px()
		let right = SKSpriteNode(imageNamed: "msg-right").px()
		
		node = SKSpriteNode()
		let scale: CGFloat = 6.5
		for part in [left, mid, bottom, right] {
				part.size.height *= scale * 1.2
				part.size.width *= scale
				node.addChild(part)
		}
		
		// Setting parts' positions
		mid.size.width = label.frame.width + mid.size.height/2
		mid.position.x = left.frame.maxX + mid.frame.width/2
		bottom.position = CGPoint(x: mid.frame.minX, y: mid.frame.minY)
		right.position.x = mid.frame.maxX + right.frame.width/2
		bottom.zPosition = 1
		
		// Tip's position
		label.position = CGPoint(x: mid.position.x, y: mid.position.y - label.frame.height/2.5)
		node.position = position
		node.zPosition = 5
		node.addChild(label)
		
		// Customizing
		if flipped { flip(scale) }
		move()
	}
	
	func flip(_ scale: CGFloat) {
		node.xScale = -scale
		node.yScale = scale
		label.xScale = -1
		label.yScale = 1
	}
	
	private func move() {
		let up = SKAction.move(by: CGVector(dx: 0, dy: 10), duration: 1.5)
		let down = SKAction.move(by: CGVector(dx: 0, dy: -10), duration: 1.5)
		up.timingMode = .easeInEaseOut; down.timingMode = .easeInEaseOut
		node.run(SKAction.repeatForever(SKAction.sequence([up, down])))
	}
}
