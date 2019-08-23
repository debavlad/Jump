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
    var node: SKSpriteNode!
    
    init(textureName: String, power: Int, harm: Int) {
        node = SKSpriteNode(imageNamed: textureName).pixelated()
        node.size = CGSize(width: 130, height: 50)
        node.name = textureName
        node.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 85, height: 1), center: CGPoint(x: 0, y: 20))
        node.physicsBody?.restitution = CGFloat(0.2)
        node.physicsBody?.friction = 0
        node.physicsBody?.mass = 10
        node.physicsBody?.linearDamping = 0
        node.physicsBody?.angularDamping = 0
        node.physicsBody?.contactTestBitMask = 0
        node.physicsBody?.categoryBitMask = Categories.platform
        node.physicsBody?.isDynamic = false
        
        node.userData = NSMutableDictionary(capacity: 2)
        node.userData?.setValue(power, forKey: "power")
        node.userData?.setValue(harm, forKey: "harm")
    }
    
    static func == (lhs: Platform, rhs: Platform) -> Bool {
        return lhs.node.hashValue == rhs.node.hashValue
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(node)
    }
}
