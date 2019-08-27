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
    public static var counter: Int = 0
    
    private var labels: Set<SKLabelNode>!
    private var particles: Set<SKEmitterNode>!
    
    private(set) var backBtn: Button!
    private var gameover: SKLabelNode!
    private(set) var line, slider, pauseBtn, darken, red, hpBorder, hpStripe: SKSpriteNode!
    private(set) var pauseTexture, playTexture: SKTexture!
    private var smokeAnim: SKAction!
    
    init(scene: SKScene, world: SKNode) {
        self.scene = scene
        labels = Set<SKLabelNode>()
        particles = Set<SKEmitterNode>()
        setNodes()
        setScene(world: world)
    }
    
    fileprivate func setScene(world: SKNode) {
        let cam = scene.childNode(withName: "Cam") as! SKCameraNode
        
        let sky = SKSpriteNode(imageNamed: "sky").pixelated()
        sky.size = CGSize(width: 754, height: 1334)
        sky.zPosition = -10
        cam.addChild(sky)
        
        let house = SKSpriteNode(imageNamed: "house").pixelated()
        house.size = CGSize(width: 543, height: 632)
        house.position = CGPoint(x: 200, y: -97.5)
//        house.position = CGPoint(x: 200, y: -147.5)
        house.zPosition = 1
        world.addChild(house)
        
        let smoke = SKSpriteNode(imageNamed: "smoke0").pixelated()
        smoke.size = CGSize(width: 119, height: 97)
        house.addChild(smoke)
        smoke.zPosition = -1
        smoke.position = CGPoint(x: -115, y: 363)
//        smoke.position = CGPoint(x: -115, y: 363)
        smoke.run(SKAction.repeatForever(smokeAnim))
        
        let bench = SKSpriteNode()
        bench.size = CGSize(width: 161, height: 34)
        bench.position = CGPoint(x: -173, y: -400)
//        bench.position = CGPoint(x: -173, y: -450)
        bench.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: bench.frame.width, height: bench.frame.height))
        bench.physicsBody?.categoryBitMask = Categories.ground
        bench.physicsBody?.isDynamic = false
        world.addChild(bench)
        
        let ground = SKSpriteNode(imageNamed: "ground").pixelated()
        ground.size = CGSize(width: 905, height: 336)
        ground.position = CGPoint(x: 30, y: -482)
//        ground.position = CGPoint(x: 30, y: -532)
        world.addChild(ground)
        
        
        let player = SKSpriteNode(imageNamed: "sit0").pixelated()
        player.name = "Character"
        player.size = CGSize(width: 48, height: 51)
        player.setScale(2.5)
        if GameScene.counter > 0 {
            player.position = CGPoint(x: -165, y: -250)
        } else {
            player.position = CGPoint(x: -165, y: -300)
        }
//        player.position = CGPoint(x: -165, y: -300)
        player.zPosition = 10
        
        hpBorder = SKSpriteNode(imageNamed: "hp-border").pixelated()
        hpBorder.size = CGSize(width: 80, height: 4)
        hpBorder.position = CGPoint(x: 0, y: 32)
        
        hpStripe = SKSpriteNode(imageNamed: "hp-green").pixelated()
        hpStripe.size = CGSize(width: 76, height: 3)
        hpStripe.anchorPoint = CGPoint(x: 0, y: 0.5)
        hpStripe.position = CGPoint(x: -38, y: 0)
        hpStripe.zPosition = -1
        hpBorder.addChild(hpStripe)
        hpBorder.alpha = 0
        
        player.addChild(hpBorder)
        world.addChild(player)
        
        line = SKSpriteNode(imageNamed: "slider-line").pixelated()
        line.size = CGSize(width: 610, height: 28)
        line.position.y = -583
        line.zPosition = 20
        line.alpha = 0
        
        slider = SKSpriteNode(imageNamed: "slider-0").pixelated()
        slider.size = CGSize(width: 54, height: 54)
        slider.position.y = 4
        slider.zPosition = 21
        
        line.addChild(slider)
        cam.addChild(line)
        
        pauseBtn = SKSpriteNode(imageNamed: "pause").pixelated()
        pauseBtn.size = CGSize(width: 106, height: 106)
        pauseBtn.position = CGPoint(x: 270, y: 572)
        pauseBtn.zPosition = 21
        pauseBtn.alpha = 0
        cam.addChild(pauseBtn)
        
        red = SKSpriteNode()
        red.size = CGSize(width: 754, height: 1334)
        red.blendMode = SKBlendMode.add
        red.color = UIColor.init(red: 120/255, green: 0, blue: 0, alpha: 1)
        red.alpha = 0
        red.zPosition = 20
        cam.addChild(red)
        
        darken = SKSpriteNode()
        darken.size = CGSize(width: 754, height: 1334)
        darken.alpha = 0
        darken.color = UIColor.black
        darken.zPosition = 20
        cam.addChild(darken)
        
        gameover = SKLabelNode(fontNamed: "FFFForward")
        gameover.fontSize = 80
        gameover.text = "Game over!"
        gameover.position.y = 250
        gameover.zPosition = 21
        gameover.alpha = 0
        cam.addChild(gameover)
        
        backBtn = Button(text: "BACK TO MENU", position: CGPoint(x: 0, y: -300))
        backBtn.node.alpha = 0
        cam.addChild(backBtn.node)
    }
    
    fileprivate func setNodes() {
        var smokeTextures: [SKTexture] = []
        for i in 0...3 {
            smokeTextures.append(SKTexture(imageNamed: "smoke\(i)").pixelated())
        }
        smokeAnim = SKAction.animate(with: smokeTextures, timePerFrame: 0.12)
        
        pauseTexture = SKTexture(imageNamed: "pause").pixelated()
        playTexture = SKTexture(imageNamed: "continue").pixelated()
    }
    
    func gameOver() {
        hideUI()
        
        fade(node: backBtn.node, to: 1.0, duration: 2, ride: false)
        fade(node: gameover, to: 1.0, duration: 2, ride: true)
        fade(node: darken, to: 0.5, duration: 1, ride: false)
        fade(node: red, to: 0.3, duration: 0.6, ride: false)
    }
    
    func fade(node: SKNode, to value: CGFloat, duration: TimeInterval, ride: Bool) {
        let fade = SKAction.fadeAlpha(to: value, duration: duration)
        fade.timingMode = SKActionTimingMode.easeOut
        fade.speed = 4
        
        if ride {
            let back = node.copy() as! SKLabelNode
            back.zPosition = node.zPosition - 1
            back.fontColor = UIColor.darkGray
            let move = SKAction.moveBy(x: -10, y: -10, duration: duration)
            move.timingMode = SKActionTimingMode.easeOut
            move.speed = 1
            node.parent!.addChild(back)
            back.run(SKAction.group([fade, move]))
        }
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
        pauseBtn.run(fade)
    }
    
    func hideUI() {
        let fade = SKAction.fadeAlpha(to: 0, duration: 1)
        fade.timingMode = SKActionTimingMode.easeOut
        fade.speed = 4
        
        line.run(fade)
        hpBorder.run(fade)
        pauseBtn.run(fade)
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
