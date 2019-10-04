//
//  Item.swift
//  Jump
//
//  Created by debavlad on 8/25/19.
//  Copyright © 2019 Vladislav Deba. All rights reserved.
//

import Foundation
import SpriteKit

class Item: Hashable {
    let sprite: SKSpriteNode
    var wasTouched = false
    
    init(sprite: SKSpriteNode) {
        self.sprite = sprite
    }
    
    func fall() {
        sprite.physicsBody?.collisionBitMask = 0
        sprite.physicsBody?.contactTestBitMask = 0
        sprite.physicsBody?.categoryBitMask = 0
        sprite.physicsBody?.allowsRotation = true
        sprite.physicsBody?.isDynamic = true
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(sprite)
    }
    
    static func == (lhs: Item, rhs: Item) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}
