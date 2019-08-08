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
    var animations = [String : SKAction]()
    
    init() {
        var wooden = [SKTexture](), golden = [SKTexture](), bronze = [SKTexture]()
        for i in 0...7 {
            wooden.append(SKTexture(imageNamed: "wooden\(i)").pixelate())
            bronze.append(SKTexture(imageNamed: "bronze\(i)").pixelate())
            golden.append(SKTexture(imageNamed: "golden\(i)").pixelate())
        }
        animations["wooden"] = SKAction.animate(with: wooden, timePerFrame: 0.1)
        animations["bronze"] = SKAction.animate(with: bronze, timePerFrame: 0.1)
        animations["golden"] = SKAction.animate(with: golden, timePerFrame: 0.1)
    }
    
    func getRandom(wooden: Double, bronze: Double, golden: Double) -> SKSpriteNode {
        let chances = [CoinType.wooden : wooden, CoinType.bronze : bronze, CoinType.golden : golden]
        
        for c in chances {
            let random = Double.random(in: 0...wooden + bronze + golden)
            if random < c.value {
                return instantiate(type: c.key)
            }
        }
        
        // if we didn't get anything in loop, return the worst
        return instantiate(type: .wooden)
    }
    
    private func instantiate(type: CoinType) -> SKSpriteNode {
        let name = type.description
        let coin = SKSpriteNode(imageNamed: name + "0")
            .setCoinSettings()
            .pixelate()
        coin.name = name + "coin"
        coin.run(SKAction.repeatForever(animations[name]!))
        coin.userData = NSMutableDictionary(capacity: 1)
        coin.userData?.setValue(false, forKey: "wasTouched")
        return coin
    }
}

enum CoinType : CustomStringConvertible {
    case wooden
    case bronze
    case golden
    
    var description: String {
        switch self {
        case .wooden:
            return "wooden"
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
