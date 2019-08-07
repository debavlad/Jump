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
    let woodenAnimation, bronzeAnimation, goldenAnimation: SKAction!
    
    init() {
        var woodenTextures: [SKTexture] = []
        var goldenTextures: [SKTexture] = []
        var bronzeTextures: [SKTexture] = []
        
        for i in 0...7 {
            woodenTextures.append(SKTexture(imageNamed: "wooden\(i)").pixelate())
            bronzeTextures.append(SKTexture(imageNamed: "bronze\(i)").pixelate())
            goldenTextures.append(SKTexture(imageNamed: "golden\(i)").pixelate())
        }
        woodenAnimation = SKAction.animate(with: woodenTextures, timePerFrame: 0.1)
        bronzeAnimation = SKAction.animate(with: bronzeTextures, timePerFrame: 0.1)
        goldenAnimation = SKAction.animate(with: goldenTextures, timePerFrame: 0.1)
    }
    
    func instantiate(type: CoinType) -> SKSpriteNode {
        let coin: SKSpriteNode!
        
        switch (type) {
        case .wooden:
            coin = SKSpriteNode(imageNamed: "wooden0")
                .setCoinSettings()
                .pixelate()
            coin.name = "woodencoin"
            coin.run(SKAction.repeatForever(woodenAnimation))
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
        
        coin.userData = NSMutableDictionary(capacity: 1)
        coin.userData?.setValue(false, forKey: "wasTouched")
        return coin
    }
}

enum CoinType {
    case wooden
    case bronze
    case golden
}

extension SKSpriteNode {
    func setCoinSettings() -> SKSpriteNode {
        size = CGSize(width: 60, height: 66)
        zPosition = 1
        let x = CGFloat.random(in: -20...20)
        position = CGPoint(x: x, y: 65)
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
