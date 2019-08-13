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
    
    func canCreate(playerY: CGFloat, gameStarted: Bool) -> Bool {
//        print ("\(lastY) + \(distance) < \(playerY) + \(height)")
        if gameStarted {
            return lastY + distance < playerY + height
        } else {
            return lastY + distance < height
        }
    }
    
    // TO-DO: clouds movement
//    func move() {
//        for cloud in collection {
//            cloud.position = CGPoint(x: cloud.position.x + 0.2, y: cloud.position.y)
//        }
//    }
    
    func remove(minY: CGFloat) {
        collection.forEach { (node) in
            if node.position.y < minY {
                node.removeFromParent()
                collection.remove(node)
            }
        }
    }
    
    func instantiate() -> SKSpriteNode {
        let cloud: SKSpriteNode!
        
        if isBackground() {
            let randomScale = CGFloat.random(in: 12...16)
            cloud = getCloud(zPos: -5, scale: randomScale, alpha: 1)
        } else {
            let randomScale = CGFloat.random(in: 22...28)
            cloud = getCloud(zPos: 15, scale: randomScale, alpha: 0.5)
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
