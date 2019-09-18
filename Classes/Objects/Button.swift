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
    let sprite: SKSpriteNode!
    private(set) var label: SKLabelNode!
    private var isPushed: Bool = false
    
    init(text: String, position: CGPoint) {
        sprite = SKSpriteNode(imageNamed: "long-btn").pixelated()
        sprite.size = CGSize(width: 575, height: 150)
        sprite.position = position
        sprite.zPosition = 21
        
        label = SKLabelNode(fontNamed: "Coder's Crux")
        label.fontColor = UIColor(red: 127/255, green: 161/255, blue: 172/255, alpha: 1)
        label.fontSize = 85
        label.zPosition = 1
        label.position.y = -8
        label.text = text
        
        sprite.addChild(label)
    }
    
    func state(pushed: Bool) {
        if pushed {
            sprite.texture = SKTexture(imageNamed: "long-btn-pushed").pixelated()
            label.position.y = -20
        } else {
            sprite.texture = SKTexture(imageNamed: "long-btn").pixelated()
            label.position.y = -8
        }
    }
}
