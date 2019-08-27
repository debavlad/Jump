//
//  PlatformFactory.swift
//  Jump
//
//  Created by Vladislav Deba on 7/30/19.
//  Copyright © 2019 Vladislav Deba. All rights reserved.
//

import Foundation
import SpriteKit

class PlatformFactory {
    var distance, lastY: CGFloat
    
    private(set) var width, height: CGFloat
    private let coinFactory: CoinFactory!
    private let foodFactory: FoodFactory!
    private(set) var collection: Set<Platform>!
    private let world: SKNode!
    
    init(world: SKNode, _ distance: CGFloat, _ lastY: CGFloat) {
        self.distance = distance
        self.lastY = lastY
        
        width = UIScreen.main.bounds.width - 100
        height = UIScreen.main.bounds.height + 50
        coinFactory = CoinFactory()
        foodFactory = FoodFactory()
        collection = Set<Platform>()
        self.world = world
    }
    
    
    func remove(minY: CGFloat) {
        collection.forEach { (platform) in
            var top = platform.node.frame.maxY
            if let item = platform.node.children.first(where: { (child) -> Bool in
                return child.name!.contains("item")
            }) {
                top += item.frame.maxY - 30
            }
            
            if top < minY {
                platform.node.removeFromParent()
                collection.remove(platform)
            }
        }
    }
    
    func remove(platform: Platform) {
        collection.remove(platform)
        platform.node.removeFromParent()
    }
    
    func create(playerY: CGFloat) {
        if can(playerY: playerY) {
            let type = getRandomType()
            let pos = CGPoint(x: CGFloat.random(in: -width...width), y: lastY + distance)
            let platform = construct(type: type, pos: pos)
            lastY = pos.y
            
            let coin = hasItem(chance: 0.5) ? coinFactory.random(wooden: 0.6, bronze: 0.2, golden: 0.1) : nil
            if let c = coin {
                platform.add(item: c)
            }
            
            let food = hasItem(chance: 0.2) ? foodFactory.random() : nil
            if let f = food {
                platform.add(item: f)
            }
            
            world.addChild(platform.node)
            collection.insert(platform)
        }
    }
    
    private func can(playerY: CGFloat) -> Bool {
        return lastY + distance < playerY + height
    }
    
    private func getRandomType() -> PlatformType {
        let random = Int.random(in: 0...3)
        return PlatformType(rawValue: random)!
    }
    
    func defineMinY() -> CGFloat {
        var minY: CGFloat = collection.first!.pos.y
        collection.forEach { (platform) in
            if platform.pos.y < minY {
                minY = platform.pos.y
            }
        }
        return minY
    }
    
    private func construct(type: PlatformType, pos: CGPoint) -> Platform {
        switch type {
        case .dirt:
            return Platform(textureName: "dirt-platform0", (pos, 75, 3))
        case .sand:
            return Platform(textureName: "sand-platform0", (pos, 80, 3))
        case .wood:
            return Platform(textureName: "wooden-platform0", (pos, 85, 4))
        case .stone:
            return Platform(textureName: "stone-platform0", (pos, 90, 4))
        }
    }
    
    private func hasItem(chance: Double) -> Bool {
        let random = Double.random(in: 0...1)
        return random <= chance
    }
    
    func findItem(pos: CGPoint) -> Item? {
        for platform in collection {
            if platform.hasItems() {
                for item in platform.items {
                    if item.node.position == pos {
                        return item
                    }
                }
            }
        }
        return nil
    }
    
    func find(pos: CGPoint) -> Platform {
        return collection.first(where: { (platform) -> Bool in
            platform.pos == pos
        })!
    }
}

enum PlatformType: Int {
    case dirt
    case sand
    case wood
    case stone
}
