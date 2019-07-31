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
    var distance, maxY: CGFloat
    let width, height: CGFloat
    
    var platforms = Set<SKSpriteNode>()
    
    init(_ distance: CGFloat, _ maxY: CGFloat, wOffset: CGFloat, hOffset: CGFloat) {
        self.distance = distance
        self.maxY = maxY
        
        width = UIScreen.main.bounds.width + wOffset
        height = UIScreen.main.bounds.height + hOffset
    }
    
    func canCreate(playerPosition: CGPoint) -> Bool {
        return maxY + distance < playerPosition.y + height
    }
    
    func instantiate() -> SKSpriteNode {
        let platform = getNewPlatform()
        let x = CGFloat.random(in: -width...width)
        let y = maxY + distance
        maxY = y
        
        platform.position = CGPoint(x: x, y: y)
        platforms.insert(platform)
        return platform
    }
    
    private func getNewPlatform() -> SKSpriteNode {
        let sample = SKSpriteNode(imageNamed: "platform")
        sample.texture?.filteringMode = .nearest
        sample.size = CGSize(width: 130, height: 50)
        
        sample.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 125, height: 1), center: CGPoint(x: 0, y: 20))
        sample.physicsBody?.restitution = CGFloat(0.2)
        sample.physicsBody?.friction = 0
        sample.physicsBody?.linearDamping = 0
        sample.physicsBody?.angularDamping = 0
        sample.physicsBody?.categoryBitMask = Categories.platformCategory
        sample.physicsBody?.contactTestBitMask = 0
        sample.physicsBody?.isDynamic = false
        
        return sample
    }
}
