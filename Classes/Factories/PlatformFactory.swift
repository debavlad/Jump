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
    private(set) var collection: Set<Platform>!
    private let data: [PlatformType : (texture: String, power: Int, damage: Int)]!
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
        collection = Set<Platform>()
        self.parent = parent
        
        data = [
            PlatformType.dirt : ("dirt-platform", 75, 3),
            PlatformType.sand : ("sand-platform", 80, 3),
            PlatformType.wood : ("wooden-platform", 85, 4),
            PlatformType.stone : ("stone-platform", 90, 4)
        ]
    }
    
    func create() {
        let type = randomType()
        lastPlatformType = type
        
        let x = CGFloat.random(in: -width...width)
        let y = highestY + CGFloat.random(in: distance)
        let pos = CGPoint(x: x, y: y)
        let platform = construct(type: type, position: pos)
        highestY = type == .dirt ? pos.y + 150: pos.y
        
        switch type {
        case .dirt:
            platform.moveByY(height: 150)
        case .sand:
            break
        case .wood, .stone:
            platform.moveByX(width: width)
        }
        
        let coin = hasItem(chance: 0.5) ? coinFactory.random(wooden: 0.6, bronze: 0.2, golden: 0.1) : nil
        if let c = coin {
            platform.add(item: c)
        }
        
        let food = hasItem(chance: 0.2) ? foodFactory.random() : nil
        if let f = food {
            platform.add(item: f)
        }
        
        parent.addChild(platform.node)
        collection.insert(platform)
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
    
    func find(item: SKNode) -> Item? {
        for platform in collection {
            if platform.hasItems() {
                if let res = platform.items.first(where: { (i) -> Bool in
                    i.node == item
                }) {
                    return res
                }
            }
        }
        return nil
    }
    
    func find(platform: SKNode) -> Platform {
        return collection.first(where: { (p) -> Bool in
            p.node == platform
        })!
    }
    
    func lowestY() -> CGFloat? {
        var minY: CGFloat? = nil
        if let first = collection.first {
            minY = first.node.position.y
            collection.forEach { (platform) in
                if platform.node.position.y < minY! {
                    minY = platform.node.position.y
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
        platform.node.position = position
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
