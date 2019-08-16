//
//  Collision.swift
//  Jump
//
//  Created by Vladislav Deba on 8/14/19.
//  Copyright © 2019 Vladislav Deba. All rights reserved.
//

import Foundation

class Collision {
    static let withPlatform = Categories.character | Categories.platform
    static let withGround = Categories.character | Categories.ground
    static let withCoin = Categories.character | Categories.coin
    static let withFood = Categories.character | Categories.food
}
