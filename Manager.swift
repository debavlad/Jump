//
//  Manager.swift
//  Jump
//
//  Created by Vladislav Deba on 8/5/19.
//  Copyright © 2019 Vladislav Deba. All rights reserved.
//

import Foundation
import SpriteKit

class Manager {
    let platforms: PlatformManager!
    let bgClouds, fgClouds: CloudManager!
    
    init(startY: CGFloat, frameMinY: CGFloat) {
        platforms = PlatformManager(150, startY)
        bgClouds = CloudManager(250, frameMinY)
        fgClouds = CloudManager(1200, frameMinY)
    }
}
