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
    let platforms: PlatformManager!
    let bgClouds, fgClouds: CloudManager!
    
    var coinsLabel: SKLabelNode!
    var sky, house, ground, bench, line, slider, button, coinstat, black, hpBorder: SKSpriteNode!
    var pauseTexture, playTexture: SKTexture!
    
    init(scene: SKScene) {
        self.scene = scene
        platforms = PlatformManager(150, scene.frame.height/2)
        bgClouds = CloudManager(250, -scene.frame.height)
        fgClouds = CloudManager(1200, -scene.frame.height)
        setNodes()
    }
    
    func setNodes() {
        sky = scene.childNode(withName: "sky")?.pixelate()
        house = scene.childNode(withName: "house")?.pixelate()
        ground = scene.childNode(withName: "ground")?.pixelate()
        bench = scene.childNode(withName: "bench")?.pixelate()
        line = scene.childNode(withName: "line")?.pixelate()
        slider = line.childNode(withName: "slider")?.pixelate()
        button = scene.childNode(withName: "button")?.pixelate()
        coinstat = scene.childNode(withName: "CoinIcon")?.pixelate()
        black = scene.childNode(withName: "black")?.pixelate()
        hpBorder = scene.childNode(withName: "character")?.childNode(withName: "hp-border")?.pixelate()
        
        pauseTexture = SKTexture(imageNamed: "pause").pixelate()
        playTexture = SKTexture(imageNamed: "continue").pixelate()
        
        ground.physicsBody?.categoryBitMask = Categories.ground
        bench.physicsBody?.categoryBitMask = Categories.ground
    }
    
    func setCamera(_ camera: SKCameraNode) {
        sky.move(toParent: camera)
        line.move(toParent: camera)
        button.move(toParent: camera)
        black.move(toParent: camera)
        coinstat.move(toParent: camera)
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
        coinstat.run(fade)
    }
    
    func hideUI() {
        let fade = SKAction.fadeAlpha(to: 0, duration: 2)
        fade.timingMode = SKActionTimingMode.easeOut
        fade.speed = 4
        
        line.run(fade)
        hpBorder.run(fade)
        button.run(fade)
        coinstat.run(fade)
    }
    // func showUI & hideUI
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
