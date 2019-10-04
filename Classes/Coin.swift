//
//  Coin.swift
//  Jump
//
//  Created by debavlad on 8/25/19.
//  Copyright © 2019 Vladislav Deba. All rights reserved.
//

import Foundation
import SpriteKit

class Coin: Item {
    var material: Currency
    
    init(node: SKSpriteNode, material: Currency) {
        self.material = material
        super.init(sprite: node, type: "coin")
    }
}
