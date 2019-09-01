//
//  Message.swift
//  Jump
//
//  Created by debavlad on 8/27/19.
//  Copyright © 2019 Vladislav Deba. All rights reserved.
//

import Foundation
import SpriteKit

class Message {
    let node: SKSpriteNode!
    let label: SKLabelNode!
    
    init(text: String, position: CGPoint, flip: Bool = false) {
        let scale: CGFloat = 6.5
        
        label = SKLabelNode(fontNamed: "Coder's Crux")
        label.text = text
        label.fontColor = .black
        label.fontSize = 50
        label.zPosition = 2
        
        let left = SKSpriteNode(imageNamed: "msg-left").pixelated()
        let mid = SKSpriteNode(imageNamed: "msg-mid").pixelated()
        let btm = SKSpriteNode(imageNamed: "msg-btm").pixelated()
        let right = SKSpriteNode(imageNamed: "msg-right").pixelated()
        
        node = SKSpriteNode()
        for part in [left, mid, btm, right] {
            part.size.height *= scale
            part.size.width *= scale
            node.addChild(part)
        }
        
        mid.size.width = label.frame.width + mid.size.height/2
        mid.position.x = left.frame.maxX + mid.frame.width/2
        btm.position = CGPoint(x: mid.frame.minX, y: mid.frame.minY)
        right.position.x = mid.frame.maxX + right.frame.width/2
        btm.zPosition = 1
        
        label.position = CGPoint(x: mid.position.x, y: mid.position.y - label.frame.height/2.5)
        node.addChild(label)
        
        node.position = position
        node.zPosition = 5
        
        if flip {
            node.xScale = -1
            label.xScale = -1
        }
        
        move()
    }
    
    func flip(scale: CGFloat) {
        node.xScale = -scale
        node.yScale = scale
        label.xScale = -1
        label.yScale = 1
    }
    
    private func move() {
        let up = SKAction.move(by: CGVector(dx: 0, dy: 10), duration: 1.5)
        up.timingMode = SKActionTimingMode.easeInEaseOut
        
        let down = SKAction.move(by: CGVector(dx: 0, dy: -10), duration: 1.5)
        down.timingMode = SKActionTimingMode.easeInEaseOut
        let seq = SKAction.sequence([up, down])
        node.run(SKAction.repeatForever(seq))
    }
}
