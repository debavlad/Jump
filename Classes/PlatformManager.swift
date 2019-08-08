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
            let coin = getRandomCoin()
            platform.addChild(coin)
        }
        
        // meals
        if hasItem(chance: 0.1) {
            let meal = getRandomFood()
            platform.addChild(meal!)
        }
        
        
        let x = CGFloat.random(in: -width...width)
        let y = lastY + distance
        platform.position = CGPoint(x: x, y: y)
        lastY = y
        
        collection.insert(platform)
        return platform
    }
    
    private func getRandomCoin() -> SKSpriteNode {
        let random = Int.random(in: 1...6)
        
        if random <= 3 {
            let woodenCoin = coins.instantiate(type: .wooden)
            return woodenCoin
        } else if random >= 4 && random <= 5 {
            let bronzeCoin = coins.instantiate(type: .bronze)
            return bronzeCoin
        } else {
            let goldenCoin = coins.instantiate(type: .golden)
            return goldenCoin
        }
    }
    
    private func getRandomFood() -> SKSpriteNode? {
        let random = Int.random(in: 1...5)
        
        switch random {
        case 1:
            let bread = meals.instantiate(type: .bread)
            return bread
        case 2:
            let cheese = meals.instantiate(type: .cheese)
            return cheese
        case 3:
            let chicken = meals.instantiate(type: .chicken)
            return chicken
        case 4:
            let egg = meals.instantiate(type: .egg)
            return egg
        case 5:
            let meat = meals.instantiate(type: .meat)
            return meat
        default:
            return nil
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
