//
//  Food.swift
//  Jump
//
//  Created by debavlad on 8/25/19.
//  Copyright © 2019 Vladislav Deba. All rights reserved.
//

import Foundation
import SpriteKit

class Food: Item {
    private(set) var energy: Int!
    
    init(sprite: SKSpriteNode, energy: Int) {
        super.init(sprite: sprite, type: "food")
        self.energy = energy
    }
}
