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
    private(set) var lbl: SKLabelNode!
    private var pushed: Bool = false
    
    init(text: String, position: CGPoint) {
        node = SKSpriteNode(imageNamed: "long-btn").pixelated()
        node.position = position
        node.zPosition = 21
        node.size = CGSize(width: 575, height: 150)
        
        lbl = SKLabelNode(fontNamed: "Coder's Crux")
        lbl.zPosition = 1
        lbl.position.y = -8
        lbl.fontSize = 85
        lbl.fontColor = UIColor(red: 127/255, green: 161/255, blue: 172/255, alpha: 1)
        lbl.text = text
        
        node.addChild(lbl)
    }
    
    func state(pushed: Bool) {
        if pushed {
            node.texture = SKTexture(imageNamed: "long-btn-pushed").pixelated()
            lbl.position.y = -20
        } else {
            node.texture = SKTexture(imageNamed: "long-btn").pixelated()
            lbl.position.y = -8
        }
    }
}
