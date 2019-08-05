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
    var distance, lastY: CGFloat
    
    private let width, height: CGFloat
    private var collection = Set<SKSpriteNode>()
    
    init(_ distance: CGFloat, _ lastY: CGFloat) {
        self.distance = distance
        self.lastY = lastY
        
        width = UIScreen.main.bounds.width + 0
        height = UIScreen.main.bounds.height + 50
    }
    
    func canCreate(playerY: CGFloat) -> Bool {
        return lastY + distance < playerY + height
    }
    
    func instantiate() -> SKSpriteNode {
        let cloud: SKSpriteNode!
        // TO-DO: random clouds scales
        if isBackground() {
            cloud = getCloud(zPos: -5, scale: 12, alpha: 1)
        } else {
            cloud = getCloud(zPos: 15, scale: 24, alpha: 0.5)
        }
        
        let x = CGFloat.random(in: -width...width)
        let y = lastY + distance
        cloud.position = CGPoint(x: x, y: y)
        lastY = y
        
        collection.insert(cloud)
        return cloud
    }
    
    private func isBackground() -> Bool {
        return distance <= 500
    }
    
    private func getCloud(zPos: CGFloat, scale: CGFloat, alpha: CGFloat ) -> SKSpriteNode {
        let index = Int.random(in: 0...3)
        let imageName = "cloud-\(index)"
        let cloud = SKSpriteNode(imageNamed: imageName).pixelate()
        
        cloud.zPosition = zPos
        cloud.setScale(scale)
        cloud.alpha = alpha
        
        let isMirrored = Bool.random()
        if isMirrored {
            cloud.xScale = -scale
        }
        return cloud
    }
}
