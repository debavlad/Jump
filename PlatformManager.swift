//
//  PlatformManager.swift
//  Jump
//
//  Created by Vladislav Deba on 7/30/19.
//  Copyright © 2019 Vladislav Deba. All rights reserved.
//

import Foundation
import SpriteKit

class PlatformManager {
    var maxY: CGFloat
    
    let width = UIScreen.main.bounds.width - 130
    let height = UIScreen.main.bounds.height + 50
    var step: CGFloat
    
    init(step: CGFloat, maxY: CGFloat) {
        self.step = step * 100
        self.maxY = maxY
    }
    
    func canCreate(characterPosition: CGPoint) -> Bool {
        let result = maxY + step < characterPosition.y + height
        print(result)
        return result
    }
    
    func instantiate() -> SKSpriteNode {
        let platform = SKSpriteNode(imageNamed: "platform_small")
        let x = CGFloat.random(in: -width...width)
        let y = maxY + step
        
        platform.texture?.filteringMode = .nearest
        platform.scale(to: CGSize(width: 5.5, height: 5.5))
        platform.size = CGSize(width: 127, height: 50)
        platform.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: platform.size.width, height: platform.size.height))
        platform.physicsBody?.restitution = CGFloat(0.2)
        platform.physicsBody?.friction = 0
        platform.physicsBody?.linearDamping = 0
        platform.physicsBody?.angularDamping = 0
        platform.physicsBody?.categoryBitMask = 0x1 << 1
        platform.physicsBody?.contactTestBitMask = 0
        platform.physicsBody?.isDynamic = false
        
        platform.position = CGPoint(x: x, y: y)
        maxY = y
        
        return platform
    }
}
