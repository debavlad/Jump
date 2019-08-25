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
    init(node: SKSpriteNode) {
        super.init(node: node, type: "coin")
    }
}
