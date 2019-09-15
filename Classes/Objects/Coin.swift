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
    var mat: CoinType
    
    init(node: SKSpriteNode, type: CoinType) {
        self.mat = type
        super.init(node: node, type: "coin")
    }
}
