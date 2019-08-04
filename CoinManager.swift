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
    var coins = Set<SKSpriteNode>()
    let coinAnimation: SKAction!
    
    init() {
        var coinTextures: [SKTexture] = []
        for i in 0...7 {
            coinTextures.append(SKTexture(imageNamed: "coin\(i)").pixelate())
        }
        coinAnimation = SKAction.animate(with: coinTextures, timePerFrame: 0.1)
    }
    
    func getCoin() -> SKSpriteNode {
        let coin = SKSpriteNode(imageNamed: "coin")
            .setCoinSettings()
            .pixelate()
        coin.run(SKAction.repeatForever(coinAnimation))
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
