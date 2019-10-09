//
//  Clouds.swift
//  Jump
//
//  Created by Vladislav Deba on 7/31/19.
//  Copyright © 2019 Vladislav Deba. All rights reserved.
//

import Foundation
import SpriteKit


class CloudFactory {
    private let parent: SKNode!
    private var bg, fg: Clouds!
    var bounds: Bounds!
    
    init(_ frame: CGRect, _ world: SKNode) {
        bg = Clouds(250, -frame.height)
        fg = Clouds(1200, -frame.height/1.25)
        self.parent = world
    }
    
    
    func create(_ playerY: CGFloat, _ started: Bool) {
        if bg.canBuild(playerY, started) {
            let cloud = bg.create()
            parent.addChild(cloud)
        }
        
        if fg.canBuild(playerY, started) {
            let cloud = fg.create()
            parent.addChild(cloud)
        }
    }
    
    func move() {
        bg.move(bounds)
        fg.move(bounds)
    }
    
    func remove() {
        bg.remove(bounds)
        fg.remove(bounds)
    }
    
    func speedUp() {
        bg.faster()
        fg.faster()
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
        self.speed = distance <= 500 ? 1 : 0.5
        
        self.width = UIScreen.main.bounds.width
        self.height = UIScreen.main.bounds.height + 50
        self.set = Set<SKSpriteNode>()
    }
    
    
    fileprivate func canBuild(_ playerY: CGFloat, _ started: Bool) -> Bool {
        if started {
            return highestY + distance < playerY + height
        } else {
            return highestY + distance < height
        }
    }
    
    func move(_ bounds: Bounds) {
        for cloud in set {
            if cloud.frame.maxY > bounds.minY {
                cloud.position.x += speed
            }
        }
    }
    
    func faster() {
        speed *= 2.5
    }
    
    func remove(_ bounds: Bounds) {
        set.forEach { (cloud) in
            if cloud.frame.maxY < bounds.minY - height*2 {
                cloud.removeFromParent()
                set.remove(cloud)
            }
            
            if cloud.position.x > 0 && set.filter({ (n) -> Bool in
                return n.position.y == cloud.position.y
            }).count <= 1 {
                let pos = CGPoint(x: bounds.minX, y: cloud.position.y)
                let new = create(pos)
                cloud.parent?.addChild(new)
                set.insert(new)
            }
            
            if cloud.frame.minX > bounds.maxX {
                cloud.removeFromParent()
                set.remove(cloud)
            }
        }
    }
    
    func create(_ position: CGPoint? = nil) -> SKSpriteNode {
        let cloud: SKSpriteNode!
        
        if background {
            let scale = CGFloat.random(in: 12...16)
            cloud = construct(-5, scale, 1)
        } else {
            let scale = CGFloat.random(in: 22...28)
            cloud = construct(15, scale, 0.5)
        }
        
        if let pos = position {
            cloud.position = pos
            cloud.position.x -= cloud.frame.width/2
        } else {
            let x = CGFloat.random(in: -width...width)
            let y = highestY + distance
            highestY = y
            cloud.position = CGPoint(x: x, y: y)
        }
        
        set.insert(cloud)
        return cloud
    }
    
    private func construct(_ z: CGFloat, _ scale: CGFloat, _ alpha: CGFloat) -> SKSpriteNode {
        let i = Int.random(in: 0...3)
        let imgName = "cloud-\(i)"
        let cloud = SKSpriteNode(imageNamed: imgName).px()
        
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
