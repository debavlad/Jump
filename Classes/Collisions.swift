//
//  Collisions.swift
//  Jump
//
//  Created by Vladislav Deba on 8/5/19.
//  Copyright © 2019 Vladislav Deba. All rights reserved.
//

import Foundation

class Collisions {
    static let characterAndWood = Categories.character | Categories.woodenPlatform
    static let characterAndStone = Categories.character | Categories.stonePlatform
    static let characterAndCoin = Categories.character | Categories.coin
    static let characterAndFood = Categories.character | Categories.food
    static let characterAndGround = Categories.character | Categories.ground
    
}
