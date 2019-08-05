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
    var distance, lastY: CGFloat

    private let width, height: CGFloat
    private let coins: CoinManager!
    private var collection = Set<SKSpriteNode>()
    
    init(_ distance: CGFloat, _ lastY: CGFloat) {
        self.distance = distance
        self.lastY = lastY
        
        width = UIScreen.main.bounds.width - 100
        height = UIScreen.main.bounds.height + 50
        coins = CoinManager()
    }
    
    func canCreate(playerY: CGFloat) -> Bool {
        return lastY + distance < playerY + height
    }
    
    func instantiate() -> SKSpriteNode {
        let platform: SKSpriteNode!
        
        let isWooden = Bool.random()
        if isWooden {
            platform = getPlatform(type: .wood)
        } else {
            platform = getPlatform(type: .stone)
        }
        platform.name = "platform"
        
        if hasItem(chance: 0.2) {
            let coin = coins.instantiate(type: CoinType.dirt)
            platform.addChild(coin)
        } else {
            if hasItem(chance: 0.2) {
                let coin = coins.instantiate(type: CoinType.bronze)
                platform.addChild(coin)
            } else {
                if hasItem(chance: 0.1) {
                    let coin = coins.instantiate(type: CoinType.golden)
                    platform.addChild(coin)
                }
            }
        }
        
        
        // TO-DO: random platform distance
        let x = CGFloat.random(in: -width...width)
        let y = lastY + distance
        platform.position = CGPoint(x: x, y: y)
        lastY = y
        
        collection.insert(platform)
        return platform
    }
    
    private func getPlatform(type: PlatformType) -> SKSpriteNode {
        var platform: SKSpriteNode!
        
        switch type {
            case .wood:
                platform = SKSpriteNode(imageNamed: "wooden-platform")
                    .setPlatformSettings()
                    .setWoodenProperties()
                    .pixelate()
            case .stone:
                platform = SKSpriteNode(imageNamed: "stone-platform")
                    .setPlatformSettings()
                    .setStoneProperties()
                    .pixelate()
        }
        
        return platform
    }
    
    private func hasItem(chance: Double) -> Bool {
        let random = Double.random(in: 0...1)
        return random <= chance
    }
}

enum PlatformType {
    case wood
    case stone
}

extension SKSpriteNode {
    func setPlatformSettings() -> SKSpriteNode {
        size = CGSize(width: 130, height: 50)
        
        physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 125, height: 1), center: CGPoint(x: 0, y: 20))
        physicsBody?.restitution = CGFloat(0.2)
        physicsBody?.friction = 0
        physicsBody?.linearDamping = 0
        physicsBody?.angularDamping = 0
        physicsBody?.contactTestBitMask = 0
        physicsBody?.isDynamic = false
        
        return self
    }
    
    func setWoodenProperties() -> SKSpriteNode {
        physicsBody?.categoryBitMask = Categories.woodenPlatform
        return self
    }
    
    func setStoneProperties() -> SKSpriteNode {
        physicsBody?.categoryBitMask = Categories.stonePlatform
        return self
    }
}
