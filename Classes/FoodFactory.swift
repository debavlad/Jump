//
//  Food.swift
//  Jump
//
//  Created by Vladislav Deba on 8/7/19.
//  Copyright © 2019 Vladislav Deba. All rights reserved.
//

import Foundation
import SpriteKit

class FoodFactory {
    private var energies = [FoodType : Int]()
    
    init() {
        energies[FoodType.meat] = 25
        energies[FoodType.chicken] = 20
        energies[FoodType.cheese] = 20
        energies[FoodType.bread] = 15
        energies[FoodType.egg] = 15
    }
    
    func getRandomFood() -> Food {
        let random = Int.random(in: 0..<energies.count)
        let type = FoodType(rawValue: random)
        let food = create(type: type!)
        
        return food
    }
    
    private func create(type: FoodType) -> Food {
        let sprite = SKSpriteNode(imageNamed: type.description)
            .setFoodSettings()
            .randomize()
            .px()
        sprite.name = type.description + "item"
        
        return Food(sprite: sprite, energy: energies[type]!)
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
    func randomize() -> SKSpriteNode {
        let x = CGFloat.random(in: -30...30)
        position = CGPoint(x: x, y: 30)
        
        let behind = Bool.random()
        zPosition = behind ? -1 : 2
        
        let mirrored = Bool.random()
        if mirrored {
            xScale = -6
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
        physicsBody?.isDynamic = false
        
        return self
    }
}
