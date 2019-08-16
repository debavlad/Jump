//
//  Platforms.swift
//  Jump
//
//  Created by Vladislav Deba on 7/30/19.
//  Copyright © 2019 Vladislav Deba. All rights reserved.
//

import Foundation
import SpriteKit

class Platforms {
    var distance, lastY: CGFloat

    private var firstJump = true
    private let width, height: CGFloat
    private let coins: Coins!
    private let food: Food!
    private var collection = Set<SKSpriteNode>()
    
    init(_ distance: CGFloat, _ lastY: CGFloat) {
        self.distance = distance
        self.lastY = lastY
        
        width = UIScreen.main.bounds.width - 100
        height = UIScreen.main.bounds.height + 50
        coins = Coins()
        food = Food()
    }
    
    func canCreate(playerY: CGFloat) -> Bool {
        return lastY + distance < playerY + height
    }
    
    func remove(minY: CGFloat) {
        collection.forEach { (node) in
            var top = node.frame.maxY
            if let item = node.children.first(where: { (child) -> Bool in
                return child.name!.contains("item")
            }) {
                top += item.frame.maxY - 30
            }
            
            if top < minY {
                node.removeFromParent()
                collection.remove(node)
            }
        }
    }
    
    func instantiate() -> SKSpriteNode {
        let type = getRandomType()
        let platform = getPlatform(type: type)
        
        if hasItem(chance: 0.5) {
            let coin = coins.getRandom(wooden: 0.6, bronze: 0.2, golden: 0.1)
            platform.addChild(coin)
        }
        if hasItem(chance: 0.1) {
            let meal = food.getRandom()
            platform.addChild(meal)
        }
        
        let x = collection.count == 5 ? -215 : CGFloat.random(in: -width...width)
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
        physicsBody?.categoryBitMask = Categories.platform
        physicsBody?.isDynamic = false
        userData = NSMutableDictionary(capacity: 2)
        
        return self
    }
    
    func setWoodenProperties() -> SKSpriteNode {
        self.userData?.setValue(75, forKey: "power")
        self.userData?.setValue(3, forKey: "harm")
        return self
    }
    
    func setStoneProperties() -> SKSpriteNode {
        self.userData?.setValue(85, forKey: "power")
        self.userData?.setValue(5, forKey: "harm")
        return self
    }
}
