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
    private let scene: SKScene!
    
    var labels: Set<SKLabelNode>!
    var particles: Set<SKEmitterNode>!
    
    private(set) var sky, house, ground, bench, line, slider, button, darken, red, hpBorder: SKSpriteNode!
    private var houseAnim: SKAction!
    private(set) var pauseTexture, playTexture: SKTexture!
    private var gameover: SKLabelNode!
    
    init(scene: SKScene, world: SKNode) {
        self.scene = scene
        labels = Set<SKLabelNode>()
        particles = Set<SKEmitterNode>()
        setNodes()
        setCam()
    }
    
    fileprivate func setNodes() {
        sky = scene.childNode(withName: "Sky")?.pixelated()
        house = scene.childNode(withName: "House")?.pixelated()
        line = scene.childNode(withName: "Line")?.pixelated()
        slider = line.childNode(withName: "Slider")?.pixelated()
        button = scene.childNode(withName: "Button")?.pixelated()
        darken = scene.childNode(withName: "Darken")?.pixelated()
        red = scene.childNode(withName: "Red")?.pixelated()
        hpBorder = scene.childNode(withName: "Character")?.childNode(withName: "HpBorder")?.pixelated()
        ground = scene.childNode(withName: "Ground")?.pixelated()
        bench = scene.childNode(withName: "Bench")?.pixelated()
        gameover = scene.childNode(withName: "GameOver") as? SKLabelNode
        
        var houseTextures: [SKTexture] = []
        for i in 0...4 {
            houseTextures.append(SKTexture(imageNamed: "house\(i)").pixelated())
        }
        houseAnim = SKAction.animate(with: houseTextures, timePerFrame: 0.12)
        house.run(SKAction.repeatForever(houseAnim))
        
        pauseTexture = SKTexture(imageNamed: "pause").pixelated()
        playTexture = SKTexture(imageNamed: "continue").pixelated()
        
        bench.physicsBody?.categoryBitMask = Categories.ground
    }
    
    fileprivate func setCam() {
        let cam = scene.childNode(withName: "Cam") as! SKCameraNode
        sky.move(toParent: cam)
        line.move(toParent: cam)
        button.move(toParent: cam)
        darken.move(toParent: cam)
        red.move(toParent: cam)
        gameover.move(toParent: cam)
    }
    
    func gameOver() {
        hideUI()
        
        fade(node: gameover, to: 1.0, duration: 2)
        fade(node: darken, to: 0.5, duration: 1)
        fade(node: red, to: 0.3, duration: 0.6)
    }
    
    func fade(node: SKNode, to value: CGFloat, duration: TimeInterval) {
        let fade = SKAction.fadeAlpha(to: value, duration: duration)
        fade.timingMode = SKActionTimingMode.easeOut
        fade.speed = 4
        
        node.run(fade)
    }
    
    func addParticles(to parent: SKNode, filename: String, pos: CGPoint) {
        let emitter = SKEmitterNode(fileNamed: filename)!
        emitter.name = String()
        emitter.position = pos
        emitter.zPosition = 3
        emitter.particleZPosition = 3
        
        let add = SKAction.run {
            parent.addChild(emitter)
        }
        let duration = emitter.particleLifetime
        let wait = SKAction.wait(forDuration: TimeInterval(duration))
        let remove = SKAction.run {
            if !parent.isPaused {
                emitter.removeFromParent()
                self.particles.remove(emitter)
            }
        }
        
        let seq = SKAction.sequence([add, wait, remove])
        scene.run(seq)
        particles.insert(emitter)
    }
    
    func removeParticles(minY: CGFloat) {
        if particles.count > 1 {
            particles.filter({ (node) -> Bool in
                return node.frame.maxY < minY
            }).forEach { (emitter) in
                particles.remove(emitter)
                emitter.removeFromParent()
            }
        }
    }
    
    func addLabel(to parent: SKNode, pos: CGPoint) {
        let lbl = SKLabelNode(text: "+1")
        lbl.name = String()
        lbl.fontName = "DisposableDroidBB"
        lbl.fontColor = UIColor.white
        lbl.fontSize = 64
        lbl.position = CGPoint(x: pos.x + 70, y: pos.y + 70)
        lbl.zPosition = 18
        
        lbl.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 50, height: 20))
        lbl.physicsBody?.collisionBitMask = 0
        lbl.physicsBody?.categoryBitMask = 0
        lbl.physicsBody?.contactTestBitMask = 0
        
        parent.addChild(lbl)
        lbl.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 60))
        let rotate = CGFloat.random(in: -0.0005...0.0005)
        lbl.physicsBody?.applyAngularImpulse(rotate)
        
        labels.insert(lbl)
    }
    
    func removeLabels(minY: CGFloat) {
        if labels.count > 0 {
            labels.filter({ (node) -> Bool in
                return node.frame.maxY < minY
            }).forEach { (label) in
                labels.remove(label)
                label.removeFromParent()
            }
        }
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
    func pixelated() -> SKSpriteNode {
        let node = self as! SKSpriteNode
        node.texture?.filteringMode = .nearest
        return node
    }
}

extension SKTexture {
    func pixelated() -> SKTexture {
        self.filteringMode = .nearest
        return self
    }
}
