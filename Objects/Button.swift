//
//  Button.swift
//  Jump
//
//  Created by debavlad on 8/27/19.
//  Copyright © 2019 Vladislav Deba. All rights reserved.
//

import Foundation
import SpriteKit

class Button {
	let node: SKSpriteNode
	let label: SKLabelNode
	
	init(_ text: String, _ y: Int) {
		node = SKSpriteNode(imageNamed: "btn1").px()
		node.name = "btn"
		node.size = CGSize(width: 575, height: 150)
		node.position = CGPoint(x: 0, y: y)
		node.zPosition = 21
		node.alpha = 0
		
		label = SKLabelNode(fontNamed: "pixelFJ8pt1")
		label.fontColor = UIColor(red: 85/255, green: 85/255, blue: 85/255, alpha: 1)
		label.fontSize = 46
		label.zPosition = 1
		label.position.y = -8
		label.text = text
		
		node.addChild(label)
	}
	
	func release() {
		node.texture = SKTexture(imageNamed: "\(node.name!)1").px()
		label.position.y = -8
	}
	
	func push() {
		node.texture = SKTexture(imageNamed: "\(node.name!)2").px()
		label.position.y = -20
	}
}
