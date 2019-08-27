//
//  Platform.swift
//  Jump
//
//  Created by debavlad on 8/18/19.
//  Copyright © 2019 Vladislav Deba. All rights reserved.
//

import Foundation
import SpriteKit

class Platform: Hashable {
    private(set) var node: SKSpriteNode!
    private(set) var items: Set<Item>!
    private(set) var power, harm: Int
    var pos: CGPoint {
        get {
            return node.position
        }
    }
    
    init(textureName: String, _ data: (pos: CGPoint, power: Int, harm: Int)) {
        node = SKSpriteNode(imageNamed: textureName).pixelated()
        node.size = CGSize(width: 130, height: 50)
        node.name = String(textureName.dropLast())
        node.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 85, height: 1), center: CGPoint(x: 0, y: 20))
        node.physicsBody?.restitution = CGFloat(0.2)
        node.physicsBody?.friction = 0
        node.physicsBody?.mass = 10
        node.physicsBody?.linearDamping = 0
        node.physicsBody?.angularDamping = 0
        node.physicsBody?.contactTestBitMask = Categories.player
        node.physicsBody?.categoryBitMask = Categories.platform
        node.physicsBody?.isDynamic = false
        node.position = data.pos
        
        self.power = data.power
        self.harm = data.harm
    }
    
    func add(item: Item) {
        if items == nil {
            items = Set<Item>()
        }
        
        items.insert(item)
        node.addChild(item.node)
    }
    
    func remove(item: Item) {
        items.remove(item)
        item.node.removeFromParent()
    }
    
    func findItem(type: String) -> Item? {
        if items != nil {
            return items.first(where: { (item) -> Bool in
                item.type == type
            })
        }
        return nil
    }
    
    func hasItems() -> Bool {
        return items != nil && items.count > 0
    }
    
    static func == (lhs: Platform, rhs: Platform) -> Bool {
        return lhs.node.hashValue == rhs.node.hashValue
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(node)
    }
}
