//
//  CloudManager.swift
//  Jump
//
//  Created by Vladislav Deba on 7/31/19.
//  Copyright © 2019 Vladislav Deba. All rights reserved.
//

import Foundation
import SpriteKit

class CloudManager {
    var distance, maxY: CGFloat
    let width, height: CGFloat
    
    var clouds = Set<SKSpriteNode>()
    
    init(_ distance: CGFloat, _ maxY: CGFloat, wOffset: CGFloat, hOffset: CGFloat) {
        self.distance = distance
        self.maxY = maxY
        
        width = UIScreen.main.bounds.width + wOffset
        height = UIScreen.main.bounds.height + hOffset
    }
    
    func canCreate(playerPosition: CGPoint) -> Bool {
        return maxY + distance < playerPosition.y + height
    }
    
    func getBackgroundCloud() -> SKSpriteNode {
        let bgCloud = getCloud(zPos: -5, scale: 12, alpha: 1)
        let x = CGFloat.random(in: -width...width)
        let y = maxY + distance
        maxY = y
        
        bgCloud.position = CGPoint(x: x, y: y)
        clouds.insert(bgCloud)
        return bgCloud
        
    }
    
    func getForegroundCloud() -> SKSpriteNode {
        let fgCloud = getCloud(zPos: 15, scale: 24, alpha: 0.5)
        let x = CGFloat.random(in: -width...width)
        let y = maxY + distance
        maxY = y
        
        fgCloud.position = CGPoint(x: x, y: y)
        clouds.insert(fgCloud)
        return fgCloud
    }
    
    func getCloud(zPos: CGFloat, scale: CGFloat, alpha: CGFloat ) -> SKSpriteNode {
        let random = Int.random(in: 1...4)
        let imageName = "cloud-\(random)"
        let newCloud = SKSpriteNode(imageNamed: imageName)
        
        newCloud.texture?.filteringMode = .nearest
        newCloud.zPosition = zPos
        newCloud.setScale(scale)
        newCloud.alpha = alpha
        
        let isMirrored = Bool.random()
        if isMirrored {
            newCloud.xScale = -scale
        }
        return newCloud
    }
}
