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
    let label: SKLabelNode!
    var loc: Location!
    
    init(text: String, size: CGFloat) {
        loc = .right
        offset = 40
        
        node = SKSpriteNode()
//        node.position = CGPoint(x: offset, y: offset)
        
        label = SKLabelNode(text: text)
        label.fontName = "Coder's Crux"
        label.fontColor = .black
        label.fontSize = size
        label.zPosition = 2
        
        let left = SKSpriteNode(imageNamed: "msg-left").pixelated()
        print("left: \(left.size)")
        left.move(toParent: node)
        
        let mid = SKSpriteNode(imageNamed: "msg-mid").pixelated()
        mid.size = CGSize(width: label.frame.width + offset, height: label.frame.height + offset)
        print("mid: \(mid.size)")
        mid.move(toParent: node)
        
        let btm = SKSpriteNode(imageNamed: "msg-btm").pixelated()
        print("btm: \(btm.size)")
        btm.move(toParent: node)
        btm.zPosition = 1
        
        let right = SKSpriteNode(imageNamed: "msg-right").pixelated()
        print("right: \(right.size)")
        right.move(toParent: node)
        
        let scale = mid.frame.height / left.frame.height
        left.setScale(scale)
        right.setScale(scale)
        btm.setScale(scale)
        
        mid.position.x = left.frame.maxX + mid.frame.width/2
        btm.position = CGPoint(x: mid.frame.minX, y: mid.frame.minY)
        right.position.x = mid.frame.maxX + right.frame.width/2
        label.position = CGPoint(x: mid.position.x, y: mid.position.y - label.frame.height/2)
        
        node.anchorPoint = CGPoint(x: 0, y: 0)
        node.position = CGPoint(x: 30, y: 60)
        node.addChild(label)
    }
    
    init(scale: CGFloat, text: String) {
        loc = .right
        offset = 27 * scale
        
        label = SKLabelNode(text: text)
        label.fontName = "Coder's Crux"
        label.fontColor = .black
        label.fontSize = 43
        label.zPosition = 2
        
        node = SKSpriteNode()
        node.position = CGPoint(x: offset, y: offset)
        
        let left = SKSpriteNode(imageNamed: "msg-left").pixelated()
        left.size = CGSize(width: 4 * scale, height: label.frame.height * scale)
        
        let mid = SKSpriteNode(imageNamed: "msg-mid").pixelated()
        mid.size = CGSize(width: label.frame.width * scale/1.7, height: label.frame.height * scale)
        mid.position.x = left.frame.maxX + mid.frame.width/2
        
        let btm = SKSpriteNode(imageNamed: "msg-btm").pixelated()
        btm.size = CGSize(width: 4 * scale, height: 4 * scale)
        btm.position = CGPoint(x: left.frame.maxX, y: left.frame.minY)
        btm.zPosition = 1
        
        let right = SKSpriteNode(imageNamed: "msg-right").pixelated()
        right.size = CGSize(width: 4 * scale, height: label.frame.height * scale)
        right.position.x = mid.frame.maxX + right.frame.width/2
        
        node.addChild(left)
        node.addChild(mid)
        node.addChild(right)
        node.addChild(btm)
        
        label.position = CGPoint(x: mid.position.x, y: mid.position.y - label.fontSize/5)
        node.anchorPoint = btm.position
        node.alpha = 0
        node.addChild(label)
    }
    
    func turn(left: Bool) {
        if loc == Location.right {
            if left {
                node.xScale = 1
                node.position.x = offset
                label.xScale = 1
            } else {
                node.xScale = -1
                node.position.x = -offset
                label.xScale = 1
            }
        } else if loc == Location.left {
            if left {
                node.xScale = -1
                node.position.x = -offset
                label.xScale = -1
            } else {
                node.xScale = 1
                node.position.x = offset
                label.xScale = -1
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
