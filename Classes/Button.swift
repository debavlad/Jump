//
//  Button.swift
//  Jump
//
//  Created by debavlad on 8/27/19.
//  Copyright © 2019 Vladislav Deba. All rights reserved.
//

import Foundation
import SpriteKit

enum BtnColor: CustomStringConvertible {
    case Gray
    case Blue
    case Green
    case Yellow
    
    var description: String {
        switch self {
        case .Gray:
            return "gray"
        case .Blue:
            return "blue"
        case .Green:
            return "green"
        case .Yellow:
            return "yellow"
        }
    }
    
    var rgb: UIColor {
        switch self {
        case .Gray:
            return UIColor(red: 149/255, green: 149/255, blue: 149/255, alpha: 1)
        case .Blue:
            return UIColor(red: 127/255, green: 161/255, blue: 172/255, alpha: 1)
        case .Green:
            return UIColor(red: 126/255, green: 171/255, blue: 135/255, alpha: 1)
        case .Yellow:
            return UIColor(red: 171/255, green: 167/255, blue: 85/255, alpha: 1)
        }
    }
}

class Button {
    var name: String
    let sprite: SKSpriteNode
    private(set) var label: SKLabelNode
    private var isPushed: Bool = false
    
    init(text: String, color: BtnColor, position: CGPoint) {
        name = "\(color.description)-btn"
        sprite = SKSpriteNode(imageNamed: "\(name)1").pixelated()
        sprite.size = CGSize(width: 575, height: 150)
        sprite.position = position
        sprite.zPosition = 21
        
        label = SKLabelNode(fontNamed: "Coder's Crux")
        label.fontColor = color.rgb
        label.fontSize = 85
        label.zPosition = 1
        label.position.y = -8
        label.text = text
        
        sprite.addChild(label)
    }
    
    init(price: Int, type: CoinType, y: CGFloat) {
        name = "\(BtnColor.Green.description)-btn"
        sprite = SKSpriteNode(imageNamed: "\(name)1").pixelated()
        sprite.size = CGSize(width: 575, height: 150)
        sprite.position.y = y
        sprite.zPosition = 21
        
        let icon = SKSpriteNode(imageNamed: "\(type.description)0").pixelated()
        icon.size = CGSize(width: 52, height: 61)
        icon.anchorPoint = CGPoint(x: 1, y: 0.5)
        
        label = SKLabelNode(fontNamed: "Coder's Crux")
        label.fontColor = BtnColor.Green.rgb
        label.fontSize = 93
        label.zPosition = 1
        label.position.y = -10
        label.text = "\(price)"
        
        icon.position = CGPoint(x: label.frame.minX - 20, y: label.frame.height/2)
        label.addChild(icon)
        
        label.position.x += 10 + icon.frame.width/2
        
        sprite.addChild(label)
    }
    
    func setPrice(amount: Int, type: CoinType) {
        label.text = "\(amount)"
        label.position.x = 0
        let icon = label.children.first! as! SKSpriteNode
        icon.texture = SKTexture(imageNamed: "\(type.description)0")
        icon.position = CGPoint(x: label.frame.minX - 20, y: label.frame.height/2)
        label.position.x += 10 + icon.frame.width/2
    }
    
    func setColor(color: BtnColor) {
        name = "\(color.description)-btn"
        sprite.texture = SKTexture(imageNamed: "\(name)1").pixelated()
        label.fontColor = color.rgb
    }
//    init(text: String, position: CGPoint) {
//        sprite = SKSpriteNode(imageNamed: "long-btn").pixelated()
//        sprite.size = CGSize(width: 575, height: 150)
//        sprite.position = position
//        sprite.zPosition = 21
//
//        label = SKLabelNode(fontNamed: "Coder's Crux")
//        label.fontColor = UIColor(red: 127/255, green: 161/255, blue: 172/255, alpha: 1)
//        label.fontSize = 85
//        label.zPosition = 1
//        label.position.y = -8
//        label.text = text
//
//        sprite.addChild(label)
//    }
    
    func state(pushed: Bool) {
        if pushed {
            sprite.texture = SKTexture(imageNamed: "\(name)2").pixelated()
            label.position.y = -20
        } else {
            sprite.texture = SKTexture(imageNamed: "\(name)1").pixelated()
            label.position.y = -8
        }
    }
}
