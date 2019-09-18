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
    var highestY: CGFloat
    let distance: ClosedRange<CGFloat>!
    private(set) var platforms: Set<Platform>!
    private(set) var items: Set<Item>!
    private let data: [PlatformType : (textureName: String, power: Int, damage: Int)]!
    private var lastPlatformType = PlatformType.dirt
    private let parent: SKNode!
    
    private let coinFactory: CoinFactory!
    private let foodFactory: FoodFactory!
    private let width, height: CGFloat
    
    
    init(parent: SKNode, startY: CGFloat, distance: ClosedRange<CGFloat>) {
        width = UIScreen.main.bounds.width - 100
        height = UIScreen.main.bounds.height + 50
        
        self.highestY = startY
        self.distance = distance
        coinFactory = CoinFactory()
        foodFactory = FoodFactory()
        platforms = Set<Platform>()
        items = Set<Item>()
        self.parent = parent
        
        data = [
            PlatformType.dirt : ("dirt-platform", 75, 2),
            PlatformType.sand : ("sand-platform", 80, 3),
            PlatformType.wood : ("wooden-platform", 85, 4),
            PlatformType.stone : ("stone-platform", 90, 5)
        ]
    }
    
    func create() {
        let type = randomType()
        lastPlatformType = type
        
        let position = CGPoint(x: CGFloat.random(in: -width...width),
                               y: highestY + CGFloat.random(in: distance))
        let platform = construct(type: type, position: position)
        highestY = type == .dirt ? position.y + 150: position.y
        
        let coin = hasItem(chance: 0.5) ? coinFactory.random(wooden: 0.6, bronze: 0.2, golden: 0.1) : nil
        if let c = coin {
            platform.add(item: c)
            items.insert(c)
        }
        
        let food = hasItem(chance: 0.2) ? foodFactory.getRandomFood() : nil
        if let f = food {
            platform.add(item: f)
            items.insert(f)
        }
        
        switch type {
        case .dirt:
            platform.moveByY(height: 150)
        case .sand:
            break
        case .wood, .stone:
            platform.moveByX(width: width)
        }
        
        parent.addChild(platform.sprite)
        platforms.insert(platform)
    }
    
    func remove(minY: CGFloat) {
        platforms.forEach { (platform) in
            var top = platform.sprite.frame.maxY
            if let item = platform.sprite.children.first(where: { (child) -> Bool in
                return child.name!.contains("item")
            }) {
                top += item.frame.maxY - 30
            }
            
            if top < minY {
                platform.sprite.removeFromParent()
                platforms.remove(platform)
            }
        }
    }
    
    func find(item node: SKNode) -> Item {
        return items.first(where: { (i) -> Bool in
            i.sprite == node
        })!
    }
    
    func remove(item: Item, from platform: Platform) {
        items.remove(item)
        platform.remove(item: item)
    }
    
    func find(platform: SKNode) -> Platform {
        return platforms.first(where: { (p) -> Bool in
            p.sprite == platform
        })!
    }
    
    func lowestY() -> CGFloat? {
        var minY: CGFloat? = nil
        if let first = platforms.first {
            minY = first.sprite.position.y
            platforms.forEach { (platform) in
                if platform.sprite.position.y < minY! {
                    minY = platform.sprite.position.y
                }
            }
        }
        return minY
    }
    
    
    func can(playerY: CGFloat) -> Bool {
        return highestY + distance.lowerBound < playerY + height
    }
    
    private func randomType() -> PlatformType {
        let random = Int.random(in: 0...3)
        return PlatformType(rawValue: random)!
    }
    
    private func construct(type: PlatformType, position: CGPoint) -> Platform {
        let platform = Platform(data[type]!)
        platform.sprite.position = position
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
