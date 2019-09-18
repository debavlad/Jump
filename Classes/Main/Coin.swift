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
    var material: CoinType
    
    init(node: SKSpriteNode, material: CoinType) {
        self.material = material
        super.init(sprite: node, type: "coin")
    }
}
