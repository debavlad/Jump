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
        let type = getRandomType()
        let platform = getPlatform(type: type)
        
        if hasItem(chance: 0.5) {
            let item = getRandomItem()
            platform.addChild(item)
        }
        
        let x = CGFloat.random(in: -width...width)
        let y = lastY + distance
        platform.position = CGPoint(x: x, y: y)
        lastY = y
        
        collection.insert(platform)
        return platform
    }
    
    private func getRandomItem() -> SKSpriteNode {
        let random = Int.random(in: 1...6)
        
        if random <= 3 {
            let dirtCoin = coins.instantiate(type: .dirt)
            return dirtCoin
        } else if random >= 4 && random <= 5 {
            let bronzeCoin = coins.instantiate(type: .bronze)
            return bronzeCoin
        } else {
            let goldenCoin = coins.instantiate(type: .golden)
            return goldenCoin
        }
    }
    
    private func getRandomType() -> PlatformType {
        let isWooden = Bool.random()
        if isWooden {
            return PlatformType.wood
        } else {
            return PlatformType.stone
        }
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
        name = "platform"
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
