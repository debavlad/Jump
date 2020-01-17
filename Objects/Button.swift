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
	var color: ButtonColor
	private(set) var label: SKLabelNode
	var coin: SKNode? {
			get { return label.children.first }
	}
	
	init(_ text: String, _ color: ButtonColor, _ pos: CGPoint) {
		self.color = color
		let name = color.description + "-btn"
		node = SKSpriteNode(imageNamed: name + "1").px()
		node.name = name
		node.size = CGSize(width: 575, height: 150)
		node.position = pos
		node.zPosition = 21
		
		label = SKLabelNode(fontNamed: "pixelFJ8pt1")
		label.fontColor = color.rgb
		label.fontSize = 46
		label.zPosition = 1
		label.position.y = -8
		label.text = text
		
		node.addChild(label)
	}
	
	init(_ price: Int, _ type: Currency, _ y: CGFloat) {
		self.color = .yellow
		let name = ButtonColor.green.description + "-btn"
		node = SKSpriteNode(imageNamed: name + "1").px()
		node.name = name
		node.size = CGSize(width: 575, height: 150)
		node.position.y = y
		node.zPosition = 21

		label = SKLabelNode(fontNamed: "pixelFJ8pt1")
		label.fontColor = ButtonColor.green.rgb
		label.fontSize = 46
		label.zPosition = 1
		label.position.y = -10
		label.text = "\(price)"
		
		let icon = SKSpriteNode(imageNamed: "\(type.rawValue)0").px()
		icon.size = CGSize(width: 52, height: 61)
		icon.anchorPoint = CGPoint(x: 1, y: 0.5)
		icon.position = CGPoint(x: label.frame.minX - 20, y: label.frame.height/2)
		label.addChild(icon)
		label.position.x += icon.frame.width/2 + 10
		node.addChild(label)
	}
	
	
	func priceContent(_ amount: Int, _ curr: Currency) {
		textContent("\(amount)")
		let node = coin as! SKSpriteNode
		node.texture = SKTexture(imageNamed: "\(curr.rawValue)0")
		node.position = CGPoint(x: label.frame.minX-20, y: label.frame.height/2)
		node.isHidden = false
		label.position.x += 10 + node.frame.width/2
	}
	
	func textContent(_ text: String) {
		label.text = text.uppercased()
		label.position.x = 0
	}
    
	func setColor(_ color: ButtonColor) {
		node.name = "\(color.description)-btn"
		node.texture = SKTexture(imageNamed: "\(node.name!)1").px()
		label.fontColor = color.rgb
		self.color = color
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

enum ButtonColor: CustomStringConvertible {
	case gray
	case blue
	case green
	case yellow
	
	var description: String {
		switch self {
		case .gray: return "gray"
		case .blue: return "blue"
		case .green: return "green"
		case .yellow: return "yellow"
		}
	}
	
	var rgb: UIColor {
		switch self {
		case .gray: return UIColor(red: 149/255, green: 149/255, blue: 149/255, alpha: 1)
		case .blue: return UIColor(red: 127/255, green: 161/255, blue: 172/255, alpha: 1)
		case .green: return UIColor(red: 126/255, green: 171/255, blue: 135/255, alpha: 1)
		case .yellow: return UIColor(red: 171/255, green: 167/255, blue: 85/255, alpha: 1)
		}
	}
}
