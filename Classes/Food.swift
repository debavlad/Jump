//
//  Food.swift
//  Jump
//
//  Created by Vladislav Deba on 8/7/19.
//  Copyright © 2019 Vladislav Deba. All rights reserved.
//

import Foundation
import SpriteKit

class Food {
    var energies = [FoodType : Int]()
    
    init() {
        energies[FoodType.meat] = 25
        energies[FoodType.chicken] = 20
        energies[FoodType.cheese] = 20
        energies[FoodType.bread] = 15
        energies[FoodType.egg] = 15
    }
    
    func getRandom() -> SKSpriteNode {
        let random = Int.random(in: 0..<energies.count)
        let type = FoodType(rawValue: random)
        let food = instantiate(type: type!)
        
        return food
    }
    
    private func instantiate(type: FoodType) -> SKSpriteNode {
        let name = type.description
        let food = SKSpriteNode(imageNamed: name)
            .setFoodSettings()
            .setRandomness()
            .pixelate()
        food.name = name + "fooditem"
        food.userData = NSMutableDictionary(capacity: 2)
        food.userData!.setValue(energies[type], forKey: "energy")
        food.userData!.setValue(false, forKey: "wasTouched")
        
        return food
    }
}

enum FoodType: Int, CustomStringConvertible {
    case chicken
    case cheese
    case meat
    case egg
    case bread
    
    var description: String {
        switch self {
        case .chicken:
            return "chicken"
        case .bread:
            return "bread"
        case .cheese:
            return "cheese"
        case .egg:
            return "egg"
        case .meat:
            return "meat"
        }
    }
}

extension SKSpriteNode {
    func setRandomness() -> SKSpriteNode {
        let x = CGFloat.random(in: -30...30)
        position = CGPoint(x: x, y: 30)
        
        let isMirrored = Bool.random()
        if isMirrored {
            xScale = -6
        }
        
        let isBehind = Bool.random()
        if isBehind {
            zPosition = -1
        } else {
            zPosition = 2
        }
        
        return self
    }
    
    func setFoodSettings() -> SKSpriteNode {
        setScale(6)
        physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: size.width, height: size.height))
        physicsBody?.affectedByGravity = true
        physicsBody?.categoryBitMask = Categories.food
        physicsBody?.contactTestBitMask = Categories.player
        physicsBody?.collisionBitMask = Categories.platform
        physicsBody?.friction = 0
        physicsBody?.restitution = 0
        physicsBody?.isDynamic = true
        
        return self
    }
}
