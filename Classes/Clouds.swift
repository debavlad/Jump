//
//  Clouds.swift
//  Jump
//
//  Created by Vladislav Deba on 7/31/19.
//  Copyright © 2019 Vladislav Deba. All rights reserved.
//

import Foundation
import SpriteKit

class Clouds {
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
            // remove if cloud is too low
            if node.position.y + node.frame.height/2 < minY {
                node.removeFromParent()
                collection.remove(node)
            }
            
            // create new if cloud is at right part of the frame
            if node.position.x > 0 && collection.filter({ (n) -> Bool in
                return n.position.y == node.position.y
            }).count <= 1 {
                let pos = CGPoint(x: minX, y: node.position.y)
                let new = generate(position: pos)
                new.position.x -= new.frame.width/2
                node.parent?.addChild(new)
                collection.insert(new)
            }
            
            // remove if cloud is too right
            if node.position.x - node.frame.width/2 > maxX {
                node.removeFromParent()
                collection.remove(node)
            }
        }
    }
    
    func generate(position: CGPoint? = nil) -> SKSpriteNode {
        let cloud: SKSpriteNode!
        
        if background() {
            let randomScale = CGFloat.random(in: 12...16)
            cloud = getCloud(z: -5, scale: randomScale, alpha: 1)
            speed = 0.5
        } else {
            let randomScale = CGFloat.random(in: 22...28)
            cloud = getCloud(z: 15, scale: randomScale, alpha: 0.5)
            speed = 0.25
        }
        
        if let pos = position {
            cloud.position = pos
            let rand = CGFloat.random(in: -200...0)
            cloud.position.x -= cloud.frame.width/2 + rand
        } else {
            let x = CGFloat.random(in: -width...width)
            let y = lastY + distance
            cloud.position = CGPoint(x: x, y: y)
            lastY = y
        }
        
        collection.insert(cloud)
        return cloud
    }
    
    func move() {
        for cloud in collection {
            cloud.position.x = cloud.position.x + speed
        }
    }
    
    private func background() -> Bool {
        return distance <= 500
    }
    
    private func getCloud(z: CGFloat, scale: CGFloat, alpha: CGFloat ) -> SKSpriteNode {
        let i = Int.random(in: 0...3)
        let imgName = "cloud-\(i)"
        let cloud = SKSpriteNode(imageNamed: imgName).pixelate()
        
        cloud.zPosition = z
        cloud.setScale(scale)
        cloud.alpha = alpha
        
        let mirrored = Bool.random()
        if mirrored {
            cloud.xScale = -scale
        }
        
        return cloud
    }
}
