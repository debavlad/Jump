//
//  Collision.swift
//  Jump
//
//  Created by Vladislav Deba on 8/14/19.
//  Copyright © 2019 Vladislav Deba. All rights reserved.
//

import Foundation

class Collision {
    static let playerPlatform = Categories.player | Categories.platform
    static let playerGround = Categories.player | Categories.ground
    static let playerCoin = Categories.player | Categories.coin
    static let playerFood = Categories.player | Categories.food
}
