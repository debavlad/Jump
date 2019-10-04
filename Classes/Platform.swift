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
    let sprite: SKSpriteNode!
    private(set) var items: Set<Item>!
    private(set) var power, damage: Int
    
    init(_ data: (textureName: String, power: Int, damage: Int)) {
        sprite = SKSpriteNode(imageNamed: data.textureName).pixelated()
        sprite.size = CGSize(width: 130, height: 50)
        sprite.name = String(data.textureName)
        sprite.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 85, height: 1), center: CGPoint(x: 0, y: 20))
        sprite.physicsBody?.restitution = CGFloat(0.2)
        sprite.physicsBody?.friction = 0
        sprite.physicsBody?.mass = 10
        sprite.physicsBody?.linearDamping = 0
        sprite.physicsBody?.angularDamping = 0
        sprite.physicsBody?.contactTestBitMask = Categories.player
        sprite.physicsBody?.categoryBitMask = Categories.platform
        sprite.physicsBody?.collisionBitMask = Categories.coin | Categories.food
        sprite.physicsBody?.isDynamic = false
        
        self.damage = data.damage
        self.power = data.power
    }

    
    func add(item: Item) {
        if items == nil {
            items = Set<Item>()
        }
        items.insert(item)
        sprite.addChild(item.sprite)
    }
    
    func remove(item: Item) {
        items.remove(item)
        item.sprite.removeFromParent()
    }
    
    func moveByX(width: CGFloat) {
        let right = SKAction.move(to: CGPoint(x: width, y: sprite.position.y), duration: 2)
        right.timingMode = SKActionTimingMode.easeInEaseOut
        let left = SKAction.move(to: CGPoint(x: -width, y: sprite.position.y), duration: 2)
        left.timingMode = SKActionTimingMode.easeInEaseOut
        
        let seq = sprite.position.x > 0 ? SKAction.sequence([left, right]) : SKAction.sequence([right, left])
        sprite.run(SKAction.repeatForever(seq))
    }
    
    func moveByY(height: CGFloat) {
        let minY = sprite.position.y, highest = sprite.position.y + height
        
        let up = SKAction.move(to: CGPoint(x: sprite.position.x, y: highest), duration: 1.5)
        up.timingMode = SKActionTimingMode.easeInEaseOut
        let down = SKAction.move(to: CGPoint(x: sprite.position.x, y: minY), duration: 1.5)
        down.timingMode = SKActionTimingMode.easeInEaseOut
        
        let seq = SKAction.sequence([up, down])
        sprite.run(SKAction.repeatForever(seq))
    }
    
    func fall(contactX: CGFloat) {
        sprite.zPosition = -1
        sprite.physicsBody?.collisionBitMask = 0
        sprite.physicsBody?.contactTestBitMask = 0
        sprite.physicsBody?.categoryBitMask = 0
        sprite.physicsBody?.isDynamic = true
        sprite.physicsBody?.allowsRotation = true
        sprite.physicsBody?.applyAngularImpulse(contactX > sprite.position.x ? -0.1 : 0.1)
        
        if hasItems() {
            for item in items {
                item.fall()
                item.sprite.physicsBody?.applyImpulse(CGVector(dx: 0, dy: -20))
            }
        }
    }
    
    func hasItems() -> Bool {
        return items != nil && items.count > 0
    }
    
    static func == (lhs: Platform, rhs: Platform) -> Bool {
        return lhs.sprite.hashValue == rhs.sprite.hashValue
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(sprite)
    }
}
