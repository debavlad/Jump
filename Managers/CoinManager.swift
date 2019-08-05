//
//  CoinManager.swift
//  Jump
//
//  Created by Vladislav Deba on 8/4/19.
//  Copyright © 2019 Vladislav Deba. All rights reserved.
//

import Foundation
import SpriteKit

class CoinManager {
    var collection = Set<SKSpriteNode>()
    let animation: SKAction!
    
    init() {
        var textures: [SKTexture] = []
        for i in 0...7 {
            textures.append(SKTexture(imageNamed: "coin\(i)").pixelate())
        }
        animation = SKAction.animate(with: textures, timePerFrame: 0.1)
    }
    
    func instantiate() -> SKSpriteNode {
        let coin = SKSpriteNode(imageNamed: "coin0")
            .setCoinSettings()
            .pixelate()
        coin.userData = NSMutableDictionary(capacity: 1)
        coin.userData?.setValue(false, forKey: "isPickedUp")
        coin.run(SKAction.repeatForever(animation))
        return coin
    }
    
    
}

extension SKSpriteNode {
    func setCoinSettings() -> SKSpriteNode {
        name = "coin"
        size = CGSize(width: 60, height: 66)
        position = CGPoint(x: -2, y: 70)
        physicsBody = SKPhysicsBody(circleOfRadius: size.width/2)
        physicsBody?.affectedByGravity = false
        physicsBody?.categoryBitMask = Categories.coin
        physicsBody?.contactTestBitMask = Categories.character
        physicsBody?.collisionBitMask = 0
        physicsBody?.friction = 0
        physicsBody?.restitution = 0
        
        return self
    }
}
