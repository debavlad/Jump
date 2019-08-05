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
    let dirtAnimation, bronzeAnimation, goldenAnimation: SKAction!
    
    init() {
        var dirtTextures: [SKTexture] = []
        var goldenTextures: [SKTexture] = []
        var bronzeTextures: [SKTexture] = []
        
        for i in 0...7 {
            dirtTextures.append(SKTexture(imageNamed: "dirt\(i)").pixelate())
            bronzeTextures.append(SKTexture(imageNamed: "bronze\(i)").pixelate())
            goldenTextures.append(SKTexture(imageNamed: "golden\(i)").pixelate())
        }
        dirtAnimation = SKAction.animate(with: dirtTextures, timePerFrame: 0.1)
        bronzeAnimation = SKAction.animate(with: bronzeTextures, timePerFrame: 0.1)
        goldenAnimation = SKAction.animate(with: goldenTextures, timePerFrame: 0.1)
    }
    
    func instantiate(type: CoinType) -> SKSpriteNode {
        let coin: SKSpriteNode!
        
        switch (type) {
        case .dirt:
            coin = SKSpriteNode(imageNamed: "dirt0")
                .setCoinSettings()
                .pixelate()
            coin.name = "dirtcoin"
            coin.run(SKAction.repeatForever(dirtAnimation))
        case .bronze:
            coin = SKSpriteNode(imageNamed: "bronze0")
                .setCoinSettings()
                .pixelate()
            coin.name = "bronzecoin"
            coin.run(SKAction.repeatForever(bronzeAnimation))
        case .golden:
            coin = SKSpriteNode(imageNamed: "golden0")
                .setCoinSettings()
                .pixelate()
            coin.name = "goldencoin"
            coin.run(SKAction.repeatForever(goldenAnimation))
        }
        
        coin.userData = NSMutableDictionary(capacity: 2)
        coin.userData?.setValue(false, forKey: "isPickedUp")
        return coin
    }
    
    
}

enum CoinType {
    case dirt
    case bronze
    case golden
}

extension SKSpriteNode {
    func setCoinSettings() -> SKSpriteNode {
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
