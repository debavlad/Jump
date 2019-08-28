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
    let offset: CGFloat
    let lbl: SKLabelNode!
    var loc: Location!
    
    init(scale: CGFloat, text: String) {
        loc = .right
        offset = 27 * scale
        
        lbl = SKLabelNode(text: text)
        lbl.fontName = "Coder's Crux"
        lbl.fontColor = .black
        lbl.fontSize = 43
        lbl.zPosition = 2
        
        node = SKSpriteNode()
        node.position = CGPoint(x: offset, y: offset)
        
        let left = SKSpriteNode(imageNamed: "msg-left").pixelated()
        left.size = CGSize(width: 4 * scale, height: lbl.frame.height * scale)
        
        let mid = SKSpriteNode(imageNamed: "msg-mid").pixelated()
        mid.size = CGSize(width: lbl.frame.width * scale/1.7, height: lbl.frame.height * scale)
        mid.position.x = left.frame.maxX + mid.frame.width/2
        
        let btm = SKSpriteNode(imageNamed: "msg-btm").pixelated()
        btm.size = CGSize(width: 4 * scale, height: 4 * scale)
        btm.position = CGPoint(x: left.frame.maxX, y: left.frame.minY)
        btm.zPosition = 1
        
        let right = SKSpriteNode(imageNamed: "msg-right").pixelated()
        right.size = CGSize(width: 4 * scale, height: lbl.frame.height * scale)
        right.position.x = mid.frame.maxX + right.frame.width/2
        
        node.addChild(left)
        node.addChild(mid)
        node.addChild(right)
        node.addChild(btm)
        
        lbl.position = CGPoint(x: mid.position.x, y: mid.position.y - lbl.fontSize/5)
        node.anchorPoint = btm.position
        node.alpha = 0
        node.addChild(lbl)
    }
    
    func turn(left: Bool) {
        if loc == Location.right {
            if left {
                node.xScale = 1
                node.position.x = offset
                lbl.xScale = 1
            } else {
                node.xScale = -1
                node.position.x = -offset
                lbl.xScale = 1
            }
        } else if loc == Location.left {
            if left {
                node.xScale = -1
                node.position.x = -offset
                lbl.xScale = -1
            } else {
                node.xScale = 1
                node.position.x = offset
                lbl.xScale = -1
            }
        }
    }
    
    func move() {
        let up = SKAction.move(by: CGVector(dx: 0, dy: 10), duration: 1.5)
        up.timingMode = SKActionTimingMode.easeInEaseOut
        
        let down = SKAction.move(by: CGVector(dx: 0, dy: -10), duration: 1.5)
        down.timingMode = SKActionTimingMode.easeInEaseOut
        let seq = SKAction.sequence([up, down])
        node.run(SKAction.repeatForever(seq))
    }
}

enum Location {
    case left
    case right
}
