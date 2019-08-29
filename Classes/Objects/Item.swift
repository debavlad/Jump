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
    let node: SKSpriteNode!
    var wasTouched = false
    let type: String!
    
    init(node: SKSpriteNode, type: String) {
        self.node = node
        self.type = type
    }
    
    func disablePhysics() {
        node.physicsBody?.collisionBitMask = 0
        node.physicsBody?.contactTestBitMask = 0
        node.physicsBody?.categoryBitMask = 0
        node.physicsBody?.allowsRotation = true
        node.physicsBody?.isDynamic = true
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(node)
    }
    
    static func == (lhs: Item, rhs: Item) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}
