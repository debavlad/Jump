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
    private let meals: FoodManager!
    private var collection = Set<SKSpriteNode>()
    
    init(_ distance: CGFloat, _ lastY: CGFloat) {
        self.distance = distance
        self.lastY = lastY
        
        width = UIScreen.main.bounds.width - 100
        height = UIScreen.main.bounds.height + 50
        coins = CoinManager()
        meals = FoodManager()
    }
    
    func canCreate(playerY: CGFloat) -> Bool {
        return lastY + distance < playerY + height
    }
    
    func remove(minY: CGFloat) {
        collection.forEach { (node) in
            if node.position.y < minY {
                node.removeFromParent()
                collection.remove(node)
            }
        }
    }
    
    func instantiate() -> SKSpriteNode {
        let type = getRandomType()
        let platform = getPlatform(type: type)
        
        // coins
        if hasItem(chance: 0.5) {
            let coin = coins.getRandom(wooden: 0.6, bronze: 0.2, golden: 0.1)
            platform.addChild(coin)
        }
        // food
        if hasItem(chance: 0.1) {
            let food = meals.getRandom()
            platform.addChild(food)
        }
        
        let x = CGFloat.random(in: -width...width)
        let y = lastY + distance
        platform.position = CGPoint(x: x, y: y)
        lastY = y
        
        collection.insert(platform)
        return platform
    }
    
    private func getRandomType() -> PlatformType {
        let random = Int.random(in: 0...1)
        return PlatformType(rawValue: random)!
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

enum PlatformType: Int {
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
