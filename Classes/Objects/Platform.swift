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
    private(set) var power, damage: Int
    
    init(_ data: (texture: String, power: Int, damage: Int)) {
        node = SKSpriteNode(imageNamed: data.texture).pixelated()
        node.size = CGSize(width: 130, height: 50)
        node.name = String(data.texture)
        node.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 85, height: 1), center: CGPoint(x: 0, y: 20))
        node.physicsBody?.restitution = CGFloat(0.2)
        node.physicsBody?.friction = 0
        node.physicsBody?.mass = 10
        node.physicsBody?.linearDamping = 0
        node.physicsBody?.angularDamping = 0
        node.physicsBody?.contactTestBitMask = Categories.player
        node.physicsBody?.categoryBitMask = Categories.platform
        node.physicsBody?.collisionBitMask = Categories.coin | Categories.food
        node.physicsBody?.isDynamic = false
        self.damage = data.damage
        self.power = data.power
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
    
    func fall(contactX: CGFloat) {
        node.zPosition = -1
        node.physicsBody?.collisionBitMask = 0
        node.physicsBody?.contactTestBitMask = 0
        node.physicsBody?.categoryBitMask = 0
        node.physicsBody?.isDynamic = true
        node.physicsBody?.allowsRotation = true
        node.physicsBody?.applyAngularImpulse(contactX > node.position.x ? -0.1 : 0.1)
        
        if hasItems() {
            for item in items {
                item.disablePhysics()
                item.node.physicsBody?.applyImpulse(CGVector(dx: 0, dy: -20))
            }
        }
    }
    
    func findItem(type: String) -> Item? {
        if hasItems() {
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
