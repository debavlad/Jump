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
    private var labels: Set<SKLabelNode>!
    private var particles: Set<SKEmitterNode>!
    
    private(set) var menuBtn: Button!
    private var gameOver: SKLabelNode!
    private(set) var door, line, slider, pauseBtn, darken, red, hpBorder, hpStripe: SKSpriteNode!
    private(set) var pauseTexture, playTexture: SKTexture!
    private(set) var smokeAnim, doorAnim: SKAction!
    
    init(scene: SKScene, world: SKNode) {
        self.scene = scene
        labels = Set<SKLabelNode>()
        particles = Set<SKEmitterNode>()
        setAnimations()
        setScene(world: world)
    }
    
    func switchUI() {
        hide(nodes: line, hpBorder, pauseBtn)
        
        fade(node: menuBtn.node, to: 1.0, duration: 2)
        fade(node: gameOver, to: 1.0, duration: 2)
        fade(node: darken, to: 0.5, duration: 1)
        fade(node: red, to: 0.3, duration: 0.6)
    }
    
    private func setScene(world: SKNode) {
        let cam = scene.childNode(withName: "Cam") as! SKCameraNode
        
        let sky = SKSpriteNode(imageNamed: "sky").pixelated()
        sky.size = CGSize(width: 754, height: 1334)
        sky.zPosition = -10
        cam.addChild(sky)
        
        let house = SKSpriteNode(imageNamed: "house").pixelated()
        house.size = CGSize(width: 543, height: 632)
        house.position = CGPoint(x: 200, y: -47)
        house.zPosition = 1
        world.addChild(house)
        
        door = SKSpriteNode(imageNamed: "door0").pixelated()
        door.size = CGSize(width: 112, height: 134)
        door.position = CGPoint(x: -119, y: -220)
        door.zPosition = 2
        house.addChild(door)
        
        let smoke = SKSpriteNode(imageNamed: "smoke0").pixelated()
        smoke.size = CGSize(width: 119, height: 97)
        house.addChild(smoke)
        smoke.zPosition = -1
        smoke.position = CGPoint(x: -115, y: 363)
        smoke.run(SKAction.repeatForever(smokeAnim))
        
        let bench = SKSpriteNode()
        bench.size = CGSize(width: 161, height: 34)
        bench.position = CGPoint(x: -173, y: -352)
        bench.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: bench.frame.width, height: bench.frame.height))
        bench.physicsBody?.categoryBitMask = Categories.ground
        bench.physicsBody?.isDynamic = false
        world.addChild(bench)
        
        let ground = SKSpriteNode(imageNamed: "ground").pixelated()
        ground.size = CGSize(width: 826, height: 518)
        ground.position = CGPoint(x: 30, y: -530)
        world.addChild(ground)
        
        
        let player = SKSpriteNode(imageNamed: "\(GameScene.skinName)-sit0").pixelated()
        player.name = "Character"
        player.size = CGSize(width: 120, height: 127.5)
        player.position = CGPoint(x: -160, y: GameScene.restarted ? -200 : -250)
        player.zPosition = 10
        
        hpBorder = SKSpriteNode(imageNamed: "hp-border").pixelated()
        hpBorder.size = CGSize(width: 84, height: 11)
        hpBorder.position = CGPoint(x: 0, y: player.frame.height/2 + 20)
        hpBorder.alpha = 0
        
        hpStripe = SKSpriteNode(imageNamed: "hp-green").pixelated()
        hpStripe.size = CGSize(width: hpBorder.frame.width - 4, height: hpBorder.frame.height - 4)
        hpStripe.anchorPoint = CGPoint(x: 0, y: 0.5)
        hpStripe.position.x = hpBorder.frame.minX + 2
        hpStripe.zPosition = -1
        
        hpBorder.addChild(hpStripe)
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
        
        gameOver = SKLabelNode(fontNamed: "FFFForward")
        gameOver.fontSize = 80
        gameOver.text = "Game over!"
        gameOver.position.y = 250
        gameOver.zPosition = 21
        gameOver.alpha = 0
        cam.addChild(gameOver)
        
        menuBtn = Button(text: "BACK TO MENU", position: CGPoint(x: 0, y: -300))
        menuBtn.node.alpha = 0
        cam.addChild(menuBtn.node)
    }
    
    private func setAnimations() {
        var smokeTextures: [SKTexture] = []
        for i in 0...3 {
            smokeTextures.append(SKTexture(imageNamed: "smoke\(i)").pixelated())
        }
        smokeAnim = SKAction.animate(with: smokeTextures, timePerFrame: 0.12)
        
        var doorTextures: [SKTexture] = []
        for i in 1...6 {
            doorTextures.append(SKTexture(imageNamed: "door\(i)").pixelated())
        }
        doorAnim = SKAction.animate(with: doorTextures, timePerFrame: 0.06)
        doorAnim.timingMode = SKActionTimingMode.easeOut
        
        pauseTexture = SKTexture(imageNamed: "pause").pixelated()
        playTexture = SKTexture(imageNamed: "continue").pixelated()
    }
    
    func addEmitter(to parent: SKNode, filename: String, position: CGPoint) {
        let emitter = SKEmitterNode(fileNamed: filename)!
        emitter.name = String()
        emitter.position = position
        emitter.zPosition = 3
        emitter.particleZPosition = 3
        
        let add = SKAction.run {
            parent.addChild(emitter)
            self.particles.insert(emitter)
        }
        let wait = SKAction.wait(forDuration: TimeInterval(emitter.particleLifetime))
        let remove = SKAction.run {
            if !parent.isPaused {
                emitter.removeFromParent()
                self.particles.remove(emitter)
            }
        }
        
        let seq = SKAction.sequence([add, wait, remove])
        scene.run(seq)
    }
    
    func addLabel(to parent: SKNode, position: CGPoint) {
        let label = SKLabelNode(text: "+1")
        label.name = String()
        label.fontName = "DisposableDroidBB"
        label.fontColor = UIColor.white
        label.fontSize = 64
        label.position = CGPoint(x: position.x + 70, y: position.y + 70)
        label.zPosition = 18
        
        label.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 50, height: 20))
        label.physicsBody?.collisionBitMask = 0
        label.physicsBody?.categoryBitMask = 0
        label.physicsBody?.contactTestBitMask = 0
        
        parent.addChild(label)
        labels.insert(label)
        label.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 60))
        let rotate = CGFloat.random(in: -0.0005...0.0005)
        label.physicsBody?.applyAngularImpulse(rotate)
    }
    
    func removeEmitters(minY: CGFloat) {
        if particles.count > 1 {
            particles.filter({ (node) -> Bool in
                return node.frame.maxY < minY
            }).forEach { (emitter) in
                particles.remove(emitter)
                emitter.removeFromParent()
            }
        }
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
    
    
    private func fade(node: SKNode, to value: CGFloat, duration: TimeInterval) {
        let fade = SKAction.fadeAlpha(to: value, duration: duration)
        fade.timingMode = SKActionTimingMode.easeOut
        fade.speed = 4
        
        if node is SKLabelNode {
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
    
    func show(nodes: SKNode...) {
        let fade = SKAction.fadeAlpha(to: 1.0, duration: 2)
        fade.timingMode = SKActionTimingMode.easeOut
        fade.speed = 4
        
        for node in nodes {
            node.run(fade)
        }
    }
    
    func hide(nodes: SKNode...) {
        let fade = SKAction.fadeAlpha(to: 0, duration: 0.6)
        fade.timingMode = SKActionTimingMode.easeOut
        fade.speed = 4
        
        for node in nodes {
            node.run(fade)
        }
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
