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
    var step: CGFloat
    
    var platforms = [SKSpriteNode]()
    
    let width = UIScreen.main.bounds.width - 130
    let height = UIScreen.main.bounds.height + 50
    var bottomCameraPosition: CGFloat!
    
    init(step: CGFloat, maxY: CGFloat) {
        self.step = step * 100
        self.maxY = maxY
    }
    
    func canCreate(characterPosition: CGPoint) -> Bool {
        return maxY + step < characterPosition.y + height
    }
    
    func canRemove(bottomCameraPosition: CGFloat) -> Bool {
        self.bottomCameraPosition = bottomCameraPosition
        return platforms.contains { (p) -> Bool in
            p.position.y < bottomCameraPosition
        }
    }
    
    func RemovePlatformsBeneath() {
        platforms.removeAll { (p) -> Bool in
            if p.position.y < bottomCameraPosition {
                p.removeFromParent()
                return true
            }
            return false
        }
    }
    
    func instantiate() -> SKSpriteNode {
        let newPlatform = getNewPlatform()
        let newX = CGFloat.random(in: -width...width)
        let newY = maxY + step
        
        newPlatform.position = CGPoint(x: newX, y: newY)
        maxY = newY
        
        platforms.append(newPlatform)
        
        return newPlatform
    }
    
    func getNewPlatform() -> SKSpriteNode {
        let sample = SKSpriteNode(imageNamed: "platform")
        sample.texture?.filteringMode = .nearest
        sample.size = CGSize(width: 130, height: 50)
        
        sample.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 105, height: 5), center: CGPoint(x: 0, y: 15))
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
