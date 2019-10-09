//
//  PlatformFactory.swift
//  Jump
//
//  Created by Vladislav Deba on 7/30/19.
//  Copyright © 2019 Vladislav Deba. All rights reserved.
//

import Foundation
import SpriteKit

class Stage {
    var availablePlatforms: [PlatformType]
    var availableCoins: [Currency]
    
    init() {
        availablePlatforms = [.sand]
        availableCoins = [.wood]
    }
    
    func upgrade(_ stage: Int) {
        switch (stage) {
        case 1:
            availablePlatforms.append(.wood)
            availableCoins.append(.bronze)
        case 2:
            availablePlatforms.append(.stone)
        case 3:
            availablePlatforms.append(.sand)
            availableCoins.append(.golden)
        default:
            break
        }
    }
}

class PlatformFactory {
    private var highestY: CGFloat
    private let distance: ClosedRange<CGFloat>
    private(set) var platforms: Set<Platform>
    private(set) var items: Set<Item>
    private let data: [PlatformType : (texture: SKTexture, power: Int, damage: Int)]
    private var lastPlatformType = PlatformType.dirt
    private let parent: SKNode!
    
    private(set) var stage: Stage
    private let coinFactory: CoinFactory
    private let foodFactory: FoodFactory
    private let width, height: CGFloat
    
    
    init(_ parent: SKNode, _ startY: CGFloat, _ distance: ClosedRange<CGFloat>) {
        width = UIScreen.main.bounds.width - 100
        height = UIScreen.main.bounds.height + 50
        
        self.highestY = startY
        self.distance = distance
        stage = Stage()
        coinFactory = CoinFactory()
        foodFactory = FoodFactory()
        platforms = Set<Platform>()
        items = Set<Item>()
        self.parent = parent
        
        data = [
            PlatformType.dirt : (SKTexture(imageNamed: "dirt-platform").px(), 73, 3),
            PlatformType.sand : (SKTexture(imageNamed: "sand-platform").px(), 78, 4),
            PlatformType.wood : (SKTexture(imageNamed: "wooden-platform").px(), 83, 5),
            PlatformType.stone : (SKTexture(imageNamed: "stone-platform").px(), 88, 6)
        ]
    }
    
    func create() {
        let type = randomType()
        lastPlatformType = type
        
        let position = CGPoint(x: CGFloat.random(in: -width...width),
                               y: highestY + CGFloat.random(in: distance))
        let platform = construct(type, position)
        highestY = type == .dirt ? position.y + 150: position.y
        
        let coin = hasItem(0.2) ? coinFactory.random(stage.availableCoins) : nil
//        let coin = hasItem(chance: 0.2) ? coinFactory.random(wooden: 0.6, bronze: 0.2, golden: 0.1) : nil
        if let c = coin {
            platform.addItem(c)
            items.insert(c)
        }
        
        let food = hasItem(0.15) ? foodFactory.getRandomFood() : nil
        if let f = food {
            platform.addItem(f)
            items.insert(f)
        }
        
        switch type {
        case .dirt:
            platform.moveByY(150)
        case .sand:
            break
        case .wood, .stone:
            platform.moveByX(width)
        }
        
        parent.addChild(platform.sprite)
        platforms.insert(platform)
    }
    
    func remove(_ minY: CGFloat) {
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
    
    func findItem(_ node: SKNode) -> Item {
        return items.first(where: { (i) -> Bool in
            i.sprite == node
        })!
    }
    
    func removeItem(_ item: Item, from platform: Platform) {
        items.remove(item)
        platform.removeItem(item)
    }
    
    func findPlatform(_ platform: SKNode) -> Platform {
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
    
    func canBuild(_ playerY: CGFloat) -> Bool {
        return highestY + distance.lowerBound < playerY + height
    }
    
    
    private func randomType() -> PlatformType {
        let random = Int.random(in: 0..<stage.availablePlatforms.count)
        return stage.availablePlatforms[random]
//        return PlatformType(rawValue: random)!
    }
    
    private func construct(_ type: PlatformType, _ position: CGPoint) -> Platform {
        let platform = Platform(type, data[type]!)
        platform.sprite.position = position
        return platform
    }
    
    private func hasItem(_ chance: Double) -> Bool {
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
