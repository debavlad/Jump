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
    
    private var speed: CGFloat
    private let width, height: CGFloat
    private var collection = Set<SKSpriteNode>()
    
    init(_ distance: CGFloat, _ lastY: CGFloat) {
        self.distance = distance
        self.lastY = lastY
        
        width = UIScreen.main.bounds.width + 0
        height = UIScreen.main.bounds.height + 50
        speed = 0
    }
    
    func canCreate(playerY: CGFloat, gameStarted: Bool) -> Bool {
        if gameStarted {
            return lastY + distance < playerY + height
        } else {
            return lastY + distance < height
        }
    }
    
    func remove(minX: CGFloat, minY: CGFloat, maxX: CGFloat) {
        collection.forEach { (node) in
            if node.position.y < minY {
                node.removeFromParent()
                collection.remove(node)
            }
            
            if node.position.x + node.frame.width / 4 > 0 && collection.filter({ (n) -> Bool in
                return n.position.y == node.position.y
            }).count <= 1 {
                let position = CGPoint(x: minX, y: node.position.y)
                let new = instantiate(position: position)
                node.parent?.addChild(new)
                collection.insert(new)
            }
            
            if node.position.x - node.frame.width / 2 > maxX {
                node.removeFromParent()
                collection.remove(node)
            }
        }
    }
    
    func instantiate(position: CGPoint? = nil) -> SKSpriteNode {
        let cloud: SKSpriteNode!
        
        if isBackground() {
            let randomScale = CGFloat.random(in: 12...16)
            cloud = getCloud(zPos: -5, scale: randomScale, alpha: 1)
            speed = 0.5
        } else {
            let randomScale = CGFloat.random(in: 22...28)
            cloud = getCloud(zPos: 15, scale: randomScale, alpha: 0.5)
            speed = 0.25
        }
        
        if position == nil {
            let x = CGFloat.random(in: -width...width)
            let y = lastY + distance
            cloud.position = CGPoint(x: x, y: y)
            lastY = y
        } else {
            cloud.position = position!
            let random = CGFloat.random(in: -200...0)
            cloud.position.x = cloud.position.x - cloud.frame.width / 2 + random
//            random = CGFloat.random(in: -30...30)
//            cloud.position.y = cloud.position.y + random
        }
        
        collection.insert(cloud)
        return cloud
    }
    
    func move() {
        for cloud in collection {
            cloud.position.x = cloud.position.x + speed
        }
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
