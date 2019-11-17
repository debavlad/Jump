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
    var name: String
    var color: BtnColor
    let sprite: SKSpriteNode
    private(set) var label: SKLabelNode
    var icon: SKNode? {
        get {
            return label.children.first
        }
    }
    
    init(_ text: String, _ color: BtnColor, _ position: CGPoint) {
        self.color = color
        name = "\(color.description)-btn"
        sprite = SKSpriteNode(imageNamed: "\(name)1").px()
        sprite.size = CGSize(width: 575, height: 150)
        sprite.position = position
        sprite.zPosition = 21
        
        label = SKLabelNode(fontNamed: "pixelFJ8pt1")
        label.fontColor = color.rgb
        label.fontSize = 46
        label.zPosition = 1
        label.position.y = -8
        label.text = text
        
        sprite.addChild(label)
    }
    
    init(_ price: Int, _ type: Currency, _ y: CGFloat) {
        self.color = BtnColor.yellow
        name = "\(BtnColor.green.description)-btn"
        sprite = SKSpriteNode(imageNamed: "\(name)1").px()
        sprite.size = CGSize(width: 575, height: 150)
        sprite.position.y = y
        sprite.zPosition = 21

        let icon = SKSpriteNode(imageNamed: "\(type.description)0").px()
        icon.size = CGSize(width: 52, height: 61)
        icon.anchorPoint = CGPoint(x: 1, y: 0.5)

        label = SKLabelNode(fontNamed: "pixelFJ8pt1")
        label.fontColor = BtnColor.green.rgb
        label.fontSize = 46
        label.zPosition = 1
        label.position.y = -10
        label.text = "\(price)"

        icon.position = CGPoint(x: label.frame.minX - 20, y: label.frame.height/2)
        label.addChild(icon)

        label.position.x += 10 + icon.frame.width/2

        sprite.addChild(label)
    }
    
    func setPrice(_ amount: Int, _ currency: Currency) {
        setText("\(amount)")
        let coin = icon as! SKSpriteNode
        coin.texture = SKTexture(imageNamed: "\(currency.description)0")
        coin.position = CGPoint(x: label.frame.minX - 20, y: label.frame.height / 2)
        coin.isHidden = false
        label.position.x += 10 + coin.frame.width/2
    }
    
    func setColor(_ color: BtnColor) {
        name = "\(color.description)-btn"
        sprite.texture = SKTexture(imageNamed: "\(name)1").px()
        self.color = color
        label.fontColor = color.rgb
    }
    
    func setText(_ text: String) {
        label.text = text
        label.position.x = 0
    }
    
    func release() {
        sprite.texture = SKTexture(imageNamed: "\(name)1").px()
        label.position.y = -8
    }
    
    func push() {
        sprite.texture = SKTexture(imageNamed: "\(name)2").px()
        label.position.y = -20
    }
}

enum BtnColor: CustomStringConvertible {
    case gray
    case blue
    case green
    case yellow
    
    var description: String {
        switch self {
        case .gray:
            return "gray"
        case .blue:
            return "blue"
        case .green:
            return "green"
        case .yellow:
            return "yellow"
        }
    }
    var rgb: UIColor {
        switch self {
        case .gray:
            return UIColor(red: 149/255, green: 149/255, blue: 149/255, alpha: 1)
        case .blue:
            return UIColor(red: 127/255, green: 161/255, blue: 172/255, alpha: 1)
        case .green:
            return UIColor(red: 126/255, green: 171/255, blue: 135/255, alpha: 1)
        case .yellow:
            return UIColor(red: 171/255, green: 167/255, blue: 85/255, alpha: 1)
        }
    }
}
