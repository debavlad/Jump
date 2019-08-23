//
//  Clouds.swift
//  Jump
//
//  Created by Vladislav Deba on 7/31/19.
//  Copyright © 2019 Vladislav Deba. All rights reserved.
//

import Foundation
import SpriteKit


class CloudsManager {
    private var bg, fg: Clouds!
    private let parent: SKNode!
    
    init(frame: CGRect, world: SKNode) {
        bg = Clouds(250, -frame.height)
        fg = Clouds(1200, -frame.height)
        self.parent = world
    }
    
    func create(playerY: CGFloat, started: Bool) {
        if bg.can(playerY: playerY, started: started) {
            let cloud = bg.create()
            parent.addChild(cloud)
        }
        
        if fg.can(playerY: playerY, started: started) {
            let cloud = fg.create()
            parent.addChild(cloud)
        }
    }
    
    func move() {
        bg.move()
        fg.move()
    }
    
    func remove(bounds: Bounds) {
        bg.remove(bounds: bounds)
        fg.remove(bounds: bounds)
    }
}

private class Clouds {
    private var distance, highestY, speed: CGFloat
    private let width, height: CGFloat
    private var set: Set<SKSpriteNode>!
    private var background: Bool {
        get {
            return distance <= 500
        }
    }
    
    init(_ distance: CGFloat, _ highestY: CGFloat) {
        self.distance = distance
        self.highestY = highestY
        self.speed = 0
        
        self.width = UIScreen.main.bounds.width
        self.height = UIScreen.main.bounds.height + 50
        self.set = Set<SKSpriteNode>()
    }
    
    func can(playerY: CGFloat, started: Bool) -> Bool {
        if started {
            return highestY + distance < playerY + height
        } else {
            return highestY + distance < height
        }
    }
    
    func move() {
        for cloud in set {
            cloud.position.x += speed
        }
    }
    
    func remove(bounds: Bounds) {
        set.forEach { (cloud) in
            if cloud.frame.maxY < bounds.minY {
                cloud.removeFromParent()
                set.remove(cloud)
            }
            
            if cloud.position.x > 0 && set.filter({ (n) -> Bool in
                return n.position.y == cloud.position.y
            }).count <= 1 {
                let pos = CGPoint(x: bounds.minX, y: cloud.position.y)
                let new = create(position: pos)
                new.position.x -= new.frame.width/2
                cloud.parent?.addChild(new)
                set.insert(new)
            }
            
            if cloud.frame.minX > bounds.maxX {
                cloud.removeFromParent()
                set.remove(cloud)
            }
        }
    }
    
    func create(position: CGPoint? = nil) -> SKSpriteNode {
        let cloud: SKSpriteNode!
        
        if background {
            let scale = CGFloat.random(in: 12...16)
            cloud = getCloud(z: -5, scale: scale, alpha: 1)
            speed = 0.5
        } else {
            let scale = CGFloat.random(in: 22...28)
            cloud = getCloud(z: 15, scale: scale, alpha: 0.5)
            speed = 0.25
        }
        
        if let pos = position {
            cloud.position = pos
            let offset = CGFloat.random(in: -200...0)
            cloud.position.x -= cloud.frame.width/2 + offset
        } else {
            let x = CGFloat.random(in: -width...width)
            let y = highestY + distance
            highestY = y
            cloud.position = CGPoint(x: x, y: y)
        }
        
        set.insert(cloud)
        return cloud
    }
    
    private func getCloud(z: CGFloat, scale: CGFloat, alpha: CGFloat) -> SKSpriteNode {
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
