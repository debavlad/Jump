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
    let scene: SKScene!
    let platforms: Platforms!
//    let bgclouds, fgclouds: Clouds!
    let clouds: CloudsManager!
    
    var sky, house, ground, bench, line, slider, button, darken, hpBorder: SKSpriteNode!
    var pauseTexture, playTexture: SKTexture!
    
    init(scene: SKScene, world: SKNode) {
        self.scene = scene
        platforms = Platforms(world: world, 150, scene.frame.height/2)
        clouds = CloudsManager(frame: scene.frame, world: world)
        
        setNodes()
        setCam()
    }
    
    func setNodes() {
        sky = scene.childNode(withName: "Sky")?.pixelate()
        house = scene.childNode(withName: "House")?.pixelate()
        line = scene.childNode(withName: "Line")?.pixelate()
        slider = line.childNode(withName: "Slider")?.pixelate()
        button = scene.childNode(withName: "Button")?.pixelate()
        darken = scene.childNode(withName: "Darken")?.pixelate()
        hpBorder = scene.childNode(withName: "Character")?.childNode(withName: "HpBorder")?.pixelate()
        ground = scene.childNode(withName: "Ground")?.pixelate()
        bench = scene.childNode(withName: "Bench")?.pixelate()
        
        pauseTexture = SKTexture(imageNamed: "pause").pixelate()
        playTexture = SKTexture(imageNamed: "continue").pixelate()
        
        ground.physicsBody?.categoryBitMask = Categories.ground
        bench.physicsBody?.categoryBitMask = Categories.ground
    }
    
    func setCam() {
        let cam = scene.childNode(withName: "Cam") as! SKCameraNode
        sky.move(toParent: cam)
        line.move(toParent: cam)
        button.move(toParent: cam)
        darken.move(toParent: cam)
    }
    
    func getParticles(filename: String) -> SKEmitterNode {
        let particles = SKEmitterNode(fileNamed: filename)!
        particles.name = String()
        particles.zPosition = 3
        particles.particleZPosition = 3
        
        return particles
    }
    
    func getLabel(text: String) -> SKLabelNode {
        let label = SKLabelNode(text: text)
        label.name = String()
        label.fontName = "DisposableDroidBB"
        label.fontColor = UIColor.white
        label.fontSize = 64
        label.position = CGPoint(x: 70, y: 70)
        label.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 50, height: 20))
        label.physicsBody?.collisionBitMask = 0
        label.physicsBody?.categoryBitMask = 0
        label.physicsBody?.contactTestBitMask = 0
        label.zPosition = 18
        return label
    }
    
    func showUI() {
        let fade = SKAction.fadeAlpha(to: 1.0, duration: 2)
        fade.timingMode = SKActionTimingMode.easeOut
        fade.speed = 4

        line.run(fade)
        hpBorder.run(fade)
        button.run(fade)
    }
    
    func hideUI() {
        let fade = SKAction.fadeAlpha(to: 0, duration: 2)
        fade.timingMode = SKActionTimingMode.easeOut
        fade.speed = 4
        
        line.run(fade)
        hpBorder.run(fade)
        button.run(fade)
    }
}

struct Bounds {
    var minY, minX, maxY, maxX: CGFloat!
}

extension SKNode {
    func pixelate() -> SKSpriteNode {
        let node = self as! SKSpriteNode
        node.texture?.filteringMode = .nearest
        return node
    }
}

extension SKTexture {
    func pixelate() -> SKTexture {
        self.filteringMode = .nearest
        return self
    }
}
