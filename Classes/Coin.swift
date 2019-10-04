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
    var currency: Currency
    
    init(node: SKSpriteNode, currency: Currency) {
        self.currency = currency
        super.init(sprite: node)
    }
}
