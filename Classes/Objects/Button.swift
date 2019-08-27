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
    let node: SKSpriteNode!
    let label: SKLabelNode!
    var pushed: Bool = false
    
    init(text: String, position: CGPoint) {
        node = SKSpriteNode(imageNamed: "btn0").pixelated()
        node.position = position
        node.zPosition = 21
        node.size = CGSize(width: 575, height: 150)
        
        label = SKLabelNode(fontNamed: "Coder's Crux")
        label.zPosition = 1
        label.position.y = -8
        label.fontSize = 85
        label.fontColor = UIColor(red: 127/255, green: 161/255, blue: 172/255, alpha: 1)
        label.text = text
        
        node.addChild(label)
    }
    
    func state(pushed: Bool) {
        if pushed {
            node.texture = SKTexture(imageNamed: "btn1").pixelated()
            label.position.y = -20
        } else {
            node.texture = SKTexture(imageNamed: "btn0").pixelated()
            label.position.y = -8
        }
    }
}
