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
    private var collection = Set<Platform>()
    private let world: SKNode!
    
    init(world: SKNode, _ distance: CGFloat, _ lastY: CGFloat) {
        self.distance = distance
        self.lastY = lastY
        
        width = UIScreen.main.bounds.width - 100
        height = UIScreen.main.bounds.height + 50
        coins = Coins()
        food = Food()
        
        self.world = world
    }
    
    private func can(playerY: CGFloat) -> Bool {
        return lastY + distance < playerY + height
    }
    
    func remove(minY: CGFloat) {
        collection.forEach { (p) in
            var top = p.node.frame.maxY
            if let item = p.node.children.first(where: { (child) -> Bool in
                return child.name!.contains("item")
            }) {
                top += item.frame.maxY - 30
            }
            
            if top < minY {
                p.node.removeFromParent()
                collection.remove(p)
            }
        }
    }
    
    func create(playerY: CGFloat) {
        if can(playerY: playerY) {
            let type = getRandomType()
            let platform = getPlatform(type: type)
            
            if hasItem(chance: 0.5) {
                let coin = coins.getRandom(wooden: 0.6, bronze: 0.2, golden: 0.1)
                platform.node.addChild(coin)
            }
            if hasItem(chance: 0.1) {
                let meal = food.getRandom()
                platform.node.addChild(meal)
            }
            
            let x = collection.count == 5 ? -215 : CGFloat.random(in: -width...width)
            let y = lastY + distance
            platform.node.position = CGPoint(x: x, y: y)
            lastY = y
            
            world.addChild(platform.node)
            collection.insert(platform)
        }
    }
    
    private func getRandomType() -> PlatformType {
        let random = Int.random(in: 0...3)
        return PlatformType(rawValue: random)!
    }
    
    private func getPlatform(type: PlatformType) -> Platform {
        var platform: Platform!
        
        switch type {
        case .dirt:
            platform = Platform(textureName: "dirt-platform", power: 75, harm: 3)
        case .sand:
            platform = Platform(textureName: "sand-platform", power: 80, harm: 3)
        case .wood:
            platform = Platform(textureName: "wooden-platform", power: 85, harm: 4)
        case .stone:
            platform = Platform(textureName: "stone-platform", power: 90, harm: 4)
        }
        
        return platform
    }

    private func hasItem(chance: Double) -> Bool {
        let random = Double.random(in: 0...1)
        return random <= chance
    }
}

enum PlatformType: Int {
    case dirt
    case sand
    case wood
    case stone
}
