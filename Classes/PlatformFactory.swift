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
    private var highestY: CGFloat
    private let distance: ClosedRange<CGFloat>
//    private(set) var platforms: Set<Platform>
    private(set) var platforms: [Platform]
    private(set) var items: Set<Item>
    private let data: [PlatformType : (texture: SKTexture, power: Int, damage: Int)]
    private var lastPlatformType = PlatformType.dirt
    private let parent: SKNode!
    private var jumpCounter = 0
    static var maxJumpQuantity = 4
    
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
        platforms = []
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
        let type = stage.availablePlatforms.randomElement()!
        lastPlatformType = type
        
        let position = CGPoint(x: CGFloat.random(in: -width...width), y: highestY + CGFloat.random(in: distance))
        let platform = construct(type, position)
        highestY = type == .dirt ? position.y + 150 : position.y
        
        if hasItem(0.2) {
            let coin = coinFactory.random(stage.availableCoins)
            platform.addItem(coin)
            items.insert(coin)
        }
        
        if jumpCounter >= PlatformFactory.maxJumpQuantity {
            let food = foodFactory.getRandomFood()
            platform.addItem(food)
            items.insert(food)
            jumpCounter = 0
        } else {
            jumpCounter += 1
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
        platforms.append(platform)
    }
    
    func clean() {
        platforms.forEach { (p) in
            p.sprite.removeFromParent()
        }
        platforms.removeAll()
    }
    
    func remove(_ minY: CGFloat) {
        if platforms.count > 0 {
            let p = platforms.first!
            var top = p.sprite.frame.maxY
            top += p.hasItems() ? p.items.first!.sprite.frame.maxY - 30 : 0
            if top < minY {
                p.sprite.removeFromParent()
                platforms.removeFirst()
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
        return platforms.first?.sprite.position.y
    }
    
    func canBuild(_ playerY: CGFloat) -> Bool {
        return highestY + distance.lowerBound < playerY + height
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


class Stage {
    var current = 0
    var availablePlatforms: [PlatformType]
    var availableCoins: [Currency]
    
    init() {
        availablePlatforms = [.sand]
        availableCoins = [.wood]
    }
    
    func setBarLabels(btm: SKLabelNode, top: SKLabelNode) {
        btm.text = "\(current)"
        top.text = "\(current+1)"
    }
    
    func upgrade(_ stage: Int) {
        switch (stage) {
        case 1:
            current = 1
            availablePlatforms.append(.wood)
            availableCoins.append(.bronze)
            PlatformFactory.maxJumpQuantity = 5
        case 2:
            current = 2
            availablePlatforms.append(.stone)
            PlatformFactory.maxJumpQuantity = 6
        case 3:
            current = 3
            availablePlatforms.append(.sand)
            availableCoins.append(.golden)
        default:
            break
        }
        
    }
}
