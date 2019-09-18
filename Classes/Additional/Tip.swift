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
    let sprite: SKSpriteNode!
    let label: SKLabelNode!
    
    init(text: String, position: CGPoint, flipped: Bool = false) {
        label = SKLabelNode(fontNamed: "Coder's Crux")
        label.text = text
        label.fontColor = .black
        label.fontSize = 50
        label.zPosition = 2
        
        // Gathering parts into one node
        let left = SKSpriteNode(imageNamed: "msg-left").pixelated()
        let mid = SKSpriteNode(imageNamed: "msg-mid").pixelated()
        let bottom = SKSpriteNode(imageNamed: "msg-btm").pixelated()
        let right = SKSpriteNode(imageNamed: "msg-right").pixelated()
        
        sprite = SKSpriteNode()
        let scale: CGFloat = 6.5
        for part in [left, mid, bottom, right] {
            part.size.height *= scale
            part.size.width *= scale
            sprite.addChild(part)
        }
        
        // Setting parts' positions
        mid.size.width = label.frame.width + mid.size.height/2
        mid.position.x = left.frame.maxX + mid.frame.width/2
        bottom.position = CGPoint(x: mid.frame.minX, y: mid.frame.minY)
        right.position.x = mid.frame.maxX + right.frame.width/2
        bottom.zPosition = 1
        
        // Tip's position
        label.position = CGPoint(x: mid.position.x, y: mid.position.y - label.frame.height/2.5)
        sprite.position = position
        sprite.zPosition = 5
        sprite.addChild(label)
        
        // Customizing
        if flipped {
            flip(scale: scale)
        }
        beginMovement()
    }
    
    func flip(scale: CGFloat) {
        sprite.xScale = -scale
        sprite.yScale = scale
        label.xScale = -1
        label.yScale = 1
    }
    
    private func beginMovement() {
        let up = SKAction.move(by: CGVector(dx: 0, dy: 10), duration: 1.5)
        up.timingMode = SKActionTimingMode.easeInEaseOut
        let down = SKAction.move(by: CGVector(dx: 0, dy: -10), duration: 1.5)
        down.timingMode = SKActionTimingMode.easeInEaseOut
        let seq = SKAction.sequence([up, down])
        sprite.run(SKAction.repeatForever(seq))
    }
}
