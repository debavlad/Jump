//
//  Coins.swift
//  Jump
//
//  Created by Vladislav Deba on 8/4/19.
//  Copyright © 2019 Vladislav Deba. All rights reserved.
//

import Foundation
import SpriteKit

class CoinFactory {
    private var animations = [String : SKAction]()
    
    init() {
        var wooden = [SKTexture](), golden = [SKTexture](), bronze = [SKTexture]()
        for i in 0...7 {
            wooden.append(SKTexture(imageNamed: "wood\(i)").pixelated())
            bronze.append(SKTexture(imageNamed: "bronze\(i)").pixelated())
            golden.append(SKTexture(imageNamed: "golden\(i)").pixelated())
        }
        animations["wood"] = SKAction.animate(with: wooden, timePerFrame: 0.1)
        animations["bronze"] = SKAction.animate(with: bronze, timePerFrame: 0.1)
        animations["golden"] = SKAction.animate(with: golden, timePerFrame: 0.1)
    }
    
    func random(wooden: Double, bronze: Double, golden: Double) -> Coin {
        let chances = [CoinType.wood : wooden, CoinType.bronze : bronze, CoinType.golden : golden]
        
        for c in chances {
            let random = Double.random(in: 0...wooden + bronze + golden)
            if random < c.value {
                return create(of: c.key)
            }
        }
        
        // return the worst platform if we didn't get anything in loop somehow
        return create(of: .wood)
    }
    
    private func create(of material: CoinType) -> Coin {
        let sprite = SKSpriteNode(imageNamed: "\(material.description)0")
            .setCoinSettings()
            .pixelated()
        sprite.name = material.description + "item"
        
        let anim = animations[material.description]!
        sprite.run(SKAction.repeatForever(anim))
        
        return Coin(node: sprite, material: material)
    }
}

enum CoinType : CustomStringConvertible {
    case wood
    case bronze
    case golden
    
    var description: String {
        switch self {
        case .wood:
            return "wood"
        case .bronze:
            return "bronze"
        case .golden:
            return "golden"
        }
    }
}

extension SKSpriteNode {
    func setCoinSettings() -> SKSpriteNode {
        size = CGSize(width: 60, height: 66)
        zPosition = 1
        let x = CGFloat.random(in: -20...20)
        position = CGPoint(x: x, y: 57)
        physicsBody = SKPhysicsBody(circleOfRadius: 35)
        physicsBody?.isDynamic = false
        physicsBody?.categoryBitMask = Categories.coin
        physicsBody?.contactTestBitMask = Categories.player
        physicsBody?.collisionBitMask = Categories.platform
        physicsBody?.friction = 0
        physicsBody?.restitution = 0
        return self
    }
}
