//
//  FoodManager.swift
//  Jump
//
//  Created by Vladislav Deba on 8/7/19.
//  Copyright © 2019 Vladislav Deba. All rights reserved.
//

import Foundation
import SpriteKit

class FoodManager {
    func instantiate(type: FoodType) -> SKSpriteNode {
        let food: SKSpriteNode!
        
        switch (type) {
        case .bread:
            food = SKSpriteNode(imageNamed: "bread")
                .setFoodSettings()
                .pixelate()
            food.name = "breadfood"
        case .cheese:
            food = SKSpriteNode(imageNamed: "cheese")
                .setFoodSettings()
                .pixelate()
            food.name = "cheesefood"
        case .chicken:
            food = SKSpriteNode(imageNamed: "chicken")
                .setFoodSettings()
                .pixelate()
            food.name = "chickenfood"
        case .egg:
            food = SKSpriteNode(imageNamed: "egg")
                .setFoodSettings()
                .pixelate()
            food.name = "eggfood"
        case .meat:
            food = SKSpriteNode(imageNamed: "meat")
                .setFoodSettings()
                .pixelate()
            food.name = "meatfood"
        }
        
        let isMirrored = Bool.random()
        if isMirrored {
            food.xScale = -6
        }
        
        let isBehind = Bool.random()
        if isBehind {
            food.zPosition = -1
        } else {
            food.zPosition = 2
        }
        
        food.userData = NSMutableDictionary(capacity: 1)
        food.userData?.setValue(false, forKey: "wasTouched")
        return food
    }
}

enum FoodType {
    case chicken
    case cheese
    case meat
    case egg
    case bread
}

extension SKSpriteNode {
    func setFoodSettings() -> SKSpriteNode {
        setScale(6)
        let x = CGFloat.random(in: -30...30)
        position = CGPoint(x: x, y: 70)
        
        physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: size.width/2, height: size.height/2))
        physicsBody?.affectedByGravity = true
        physicsBody?.categoryBitMask = Categories.food
        physicsBody?.contactTestBitMask = Categories.character
        physicsBody?.collisionBitMask = Categories.woodenPlatform | Categories.stonePlatform
        physicsBody?.friction = 0
        physicsBody?.restitution = 0
        
        return self
    }
}
