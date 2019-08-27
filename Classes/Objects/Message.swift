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
    let scale, offset: CGFloat
    
    init(scale: CGFloat, length: CGFloat) {
        offset = 25
        self.scale = scale
        
        node = SKSpriteNode()
        node.anchorPoint = CGPoint(x: 0, y: 0)
        node.position = CGPoint(x: offset, y: offset)
        
        let left = SKSpriteNode(imageNamed: "msg-left").pixelated()
        left.setScale(scale)
        
        let mid = SKSpriteNode(imageNamed: "msg-mid").pixelated()
        mid.yScale = scale
        mid.xScale = scale * length
        mid.anchorPoint = CGPoint(x: 0, y: 0)
        mid.position.x = left.frame.maxX
        mid.position.y = left.frame.minY
        
        let btm = SKSpriteNode(imageNamed: "msg-btm").pixelated()
        btm.setScale(scale)
        btm.anchorPoint = CGPoint(x: 0, y: 0.5)
        btm.zPosition = 1
        btm.position.x = mid.frame.minX
        btm.position.y = mid.frame.minY
        
        let right = SKSpriteNode(imageNamed: "msg-right").pixelated()
        right.setScale(scale)
        right.anchorPoint = CGPoint(x: 0, y: 0.5)
        right.position.x = mid.frame.maxX
        
        node.addChild(left)
        node.addChild(mid)
        node.addChild(right)
        node.addChild(btm)
    }
}
