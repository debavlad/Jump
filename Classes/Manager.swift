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
    let bgClouds, fgClouds: Clouds!
    
    var sky, house, ground, bench, line, slider, button, black, hpBorder: SKSpriteNode!
    var pauseTexture, playTexture: SKTexture!
    
    init(scene: SKScene) {
        self.scene = scene
        platforms = Platforms(150, scene.frame.height/2)
        bgClouds = Clouds(250, -scene.frame.height)
        fgClouds = Clouds(1200, -scene.frame.height)
        
        setNodes()
        setCam()
    }
    
    func setNodes() {
        sky = scene.childNode(withName: "sky")?.pixelate()
        house = scene.childNode(withName: "house")?.pixelate()
        ground = scene.childNode(withName: "ground")?.pixelate()
        bench = scene.childNode(withName: "bench")?.pixelate()
        line = scene.childNode(withName: "line")?.pixelate()
        slider = line.childNode(withName: "slider")?.pixelate()
        button = scene.childNode(withName: "button")?.pixelate()
        black = scene.childNode(withName: "black")?.pixelate()
        hpBorder = scene.childNode(withName: "character")?.childNode(withName: "hp-border")?.pixelate()
        
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
        black.move(toParent: cam)
    }
    
    func getParticles(filename: String, targetNode: SKNode?) -> SKEmitterNode {
        let particles = SKEmitterNode(fileNamed: filename)!
        particles.name = String()
        particles.zPosition = 3
        particles.particleZPosition = 3
        
        if filename != "DustParticles" {
            particles.targetNode = targetNode
        }
        
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
