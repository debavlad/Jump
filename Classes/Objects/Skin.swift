//
//  Skin.swift
//  Jump
//
//  Created by debavlad on 9/4/19.
//  Copyright © 2019 Vladislav Deba. All rights reserved.
//

import Foundation
import SpriteKit

class Skin {
    var name: String
    var textureName: String
    
    init(name: String, textureName: String) {
        self.name = name.uppercased()
//        self.texture = SKTexture(imageNamed: textureName).pixelated()
        self.textureName = textureName
    }
}
