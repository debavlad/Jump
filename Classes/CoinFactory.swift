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
        setAnimations()
    }
    
    func setAnimations() {
        var textures = [SKTexture]()
        for i in 0...7 {
            textures.append(SKTexture(imageNamed: "wood\(i)").px())
        }
        animations["wood"] = SKAction.animate(with: textures, timePerFrame: 0.1)
        textures.removeAll(keepingCapacity: true)
        
        for i in 0...7 {
            textures.append(SKTexture(imageNamed: "bronze\(i)").px())
        }
        animations["bronze"] = SKAction.animate(with: textures, timePerFrame: 0.1)
        textures.removeAll(keepingCapacity: true)
        
        for i in 0...7 {
            textures.append(SKTexture(imageNamed: "golden\(i)").px())
        }
        animations["golden"] = SKAction.animate(with: textures, timePerFrame: 0.1)
        textures.removeAll()
    }
    
    func random(wooden: Double, bronze: Double, golden: Double) -> Coin {
        let chances = [Currency.wood : wooden, Currency.bronze : bronze, Currency.golden : golden]
        
        for c in chances {
            let random = Double.random(in: 0...wooden + bronze + golden)
            if random < c.value {
                return create(of: c.key)
            }
        }
        
        // return the worst platform if we didn't get anything in loop somehow
        return create(of: .wood)
    }
    
    private func create(of currency: Currency) -> Coin {
        let sprite = SKSpriteNode(imageNamed: "\(currency.description)0")
            .setCoinSettings()
            .px()
        sprite.name = currency.description + "item"
        
        let anim = animations[currency.description]!
        sprite.run(SKAction.repeatForever(anim))
        
        return Coin(node: sprite, currency: currency)
    }
}

enum Currency : CustomStringConvertible {
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
