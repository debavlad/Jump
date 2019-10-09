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
    
    private var width, height: CGFloat
    private(set) var menuBtn, advBtn: Button!
    private(set) var gameOver, gameScore, menuScore, ptsScore, lblScore, wLabel, bLabel, gLabel, wl, bl, gl: SKLabelNode!
    private(set) var house, door, line, slider, pauseBtn, darken, red, hpBorder, hpStripe, mScore, wIcon, bIcon, gIcon, w, b, g: SKSpriteNode!
    private(set) var pauseTexture, playTexture: SKTexture!
    private(set) var smokeAnim, doorAnim: SKAction!
    
    init(scene: SKScene, world: SKNode) {
        self.scene = scene
        width = UIScreen.main.bounds.width
        height = UIScreen.main.bounds.height
        labels = Set<SKLabelNode>()
        particles = Set<SKEmitterNode>()
        setAnimations()
        setScene(world: world)
    }
    
    func switchUI() {
        hide(nodes: line, hpBorder, pauseBtn)
        
        // Centering coins' stats
        for (icon, lbl) in [(wIcon, wLabel), (bIcon, bLabel), (gIcon, gLabel)] {
            icon!.position.x = -lbl!.frame.width/2
            lbl!.position.x = icon!.frame.maxX + lbl!.frame.width + 30
        }
        
        fade(node: advBtn.sprite, to: 1.0, duration: 2, false)
        fade(node: menuBtn.sprite, to: 1.0, duration: 2, false)
        fade(node: wIcon, to: 1.0, duration: 2, false)
        fade(node: bIcon, to: 1.0, duration: 2, false)
        fade(node: gIcon, to: 1.0, duration: 2, false)
        fade(node: gameOver, to: 1.0, duration: 2, true)
        fade(node: mScore, to: 1.0, duration: 2, false)
        fade(node: darken, to: 0.6, duration: 1, false)
        fade(node: red, to: 0.4, duration: 0.6, false)
    }
    
    private func setScene(world: SKNode) {
        let cam = scene.childNode(withName: "Cam") as! SKCameraNode
        
        let sky = SKSpriteNode(imageNamed: "sky").px()
        sky.size = scene.frame.size
        sky.zPosition = -10
        cam.addChild(sky)
        
        house = SKSpriteNode(imageNamed: "house").px()
        house.size = CGSize(width: 543, height: 632)
        house.position = CGPoint(x: 200, y: -47)
        house.zPosition = 1
        world.addChild(house)
        
        door = SKSpriteNode(imageNamed: "door0").px()
        door.size = CGSize(width: 112, height: 134)
        door.position = CGPoint(x: -119, y: -220)
        door.zPosition = 2
        house.addChild(door)
        
        let smoke = SKSpriteNode(imageNamed: "smoke0").px()
        smoke.size = CGSize(width: 119, height: 97)
        house.addChild(smoke)
        smoke.zPosition = -1
        smoke.position = CGPoint(x: -115, y: 363)
        smoke.run(SKAction.repeatForever(smokeAnim))
        
        let bench = SKSpriteNode()
        bench.size = CGSize(width: 161, height: 34)
        bench.position = CGPoint(x: -173, y: -347)
        bench.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: bench.frame.width, height: bench.frame.height))
        bench.physicsBody?.categoryBitMask = Categories.ground
        bench.physicsBody?.isDynamic = false
        world.addChild(bench)
        
        let ground = SKSpriteNode(imageNamed: "ground").px()
        ground.size = CGSize(width: 826, height: 518)
        ground.position = CGPoint(x: 30, y: -530)
        world.addChild(ground)
        
        
//        let player = SKSpriteNode(imageNamed: "\(GameScene.currentSkin!.name)-sit0").px()
        let player = SKSpriteNode(imageNamed: "\(ShopScene.skins[GameScene.skinIndex].name)-sit0").px()
        player.name = "Character"
        player.size = CGSize(width: 132, height: 140)
        player.position = CGPoint(x: -160, y: GameScene.restarted ? -200 : -250)
        player.zPosition = 10
        
        hpBorder = SKSpriteNode(imageNamed: "hp-border").px()
        hpBorder.size = CGSize(width: 84, height: 11)
        hpBorder.position = CGPoint(x: 0, y: player.frame.height/2 + 10)
        hpBorder.alpha = 0
        
        hpStripe = SKSpriteNode(imageNamed: "hp-green").px()
        hpStripe.size = CGSize(width: hpBorder.frame.width - 4, height: hpBorder.frame.height - 4)
        hpStripe.anchorPoint = CGPoint(x: 0, y: 0.5)
        hpStripe.position.x = hpBorder.frame.minX + 2
        hpStripe.zPosition = -1
        
        hpBorder.addChild(hpStripe)
        player.addChild(hpBorder)
        world.addChild(player)
        
        line = SKSpriteNode(imageNamed: "slider-line").px()
        line.size = CGSize(width: 610, height: 28)
        line.position.y = -height + 90
        line.zPosition = 20
        line.alpha = 0
        
        slider = SKSpriteNode(imageNamed: "slider-0").px()
        slider.size = CGSize(width: 54, height: 54)
        slider.position.y = 4
        slider.zPosition = 21
        
        line.addChild(slider)
        cam.addChild(line)
        
        pauseBtn = SKSpriteNode(imageNamed: "pause").px()
        pauseBtn.size = CGSize(width: 106, height: 106)
        pauseBtn.position.y = height - 100
        pauseBtn.position.x = width - 100
        pauseBtn.position = CGPoint(x: width - 100, y: height - 100)
        pauseBtn.zPosition = 21
        pauseBtn.alpha = 0
        cam.addChild(pauseBtn)
        
        red = SKSpriteNode()
        red.size = scene.frame.size
        red.blendMode = SKBlendMode.add
        red.color = UIColor.init(red: 120/255, green: 0, blue: 0, alpha: 1)
        red.alpha = 0
        red.zPosition = 20
        cam.addChild(red)
        
        darken = SKSpriteNode()
        darken.size = scene.frame.size
        darken.alpha = 0
        darken.color = UIColor.black
        darken.zPosition = 20
        cam.addChild(darken)
        
        gameOver = SKLabelNode(fontNamed: "FFFForward")
        gameOver.fontSize = 80
        gameOver.text = "Game over!"
        gameOver.position.y = 460
        gameOver.zPosition = 21
        gameOver.alpha = 0
        cam.addChild(gameOver)
        
        menuScore = SKLabelNode(fontNamed: "Coder's Crux")
        
        mScore = SKSpriteNode()
        mScore.zPosition = 21
        mScore.alpha = 0
        mScore.position = CGPoint(x: gameOver.position.x, y: gameOver.position.y - 100)
        
        lblScore = SKLabelNode(fontNamed: "Coder's Crux")
        lblScore.text = "SCORE:"
        lblScore.fontSize = 90
        mScore.addChild(lblScore)
        
        ptsScore = SKLabelNode(fontNamed: "Coder's Crux")
        ptsScore.text = "0"
        ptsScore.fontSize = 90
        ptsScore.fontColor = UIColor(red: 253/255, green: 255/255, blue: 115/255, alpha: 1)
        ptsScore.position.x = lblScore.frame.maxX + ptsScore.frame.width/2 + 15
        mScore.addChild(ptsScore)
        cam.addChild(mScore)
        
        gameScore = SKLabelNode(fontNamed: "FFFForward")
        gameScore.zPosition = 21
        gameScore.alpha = 0
        gameScore.text = "0"
        gameScore.fontSize = 50
        gameScore.position = CGPoint(x: -width + gameScore.frame.width/2 + 100, y: height - gameScore.frame.height/2 - 100)
        gameScore.fontColor = UIColor(red: 84/255, green: 84/255, blue: 84/255, alpha: 1)
        cam.addChild(gameScore)
        
        var icons = SKNode()
        
        wIcon = SKSpriteNode(imageNamed: "wood0").px()
        wIcon.size = CGSize(width: 90, height: 99)
        wIcon.position.y = 180 // +50
        wIcon.zPosition = 21
        wIcon.alpha = 0
        icons.addChild(wIcon)

        wLabel = SKLabelNode(fontNamed: "Coder's Crux")
        wLabel.text = "0"
        wLabel.fontSize = 140
        wLabel.position = CGPoint(x: 0, y: -wLabel.frame.height/2 + 4)
        wIcon.addChild(wLabel)
        
        bIcon = SKSpriteNode(imageNamed: "bronze0").px()
        bIcon.size = CGSize(width: 90, height: 99)
        bIcon.position.y = 30
        bIcon.zPosition = 21
        bIcon.alpha = 0
        icons.addChild(bIcon)
        
        bLabel = SKLabelNode(fontNamed: "Coder's Crux")
        bLabel.text = "0"
        bLabel.fontSize = 140
        bLabel.position = CGPoint(x: 0, y: -bLabel.frame.height/2 + 4)
        bIcon.addChild(bLabel)
        
        gIcon = SKSpriteNode(imageNamed: "golden0").px()
        gIcon.size = CGSize(width: 90, height: 99)
        gIcon.position.y = -120
        gIcon.zPosition = 21
        gIcon.alpha = 0
        icons.addChild(gIcon)
        
        gLabel = SKLabelNode(fontNamed: "Coder's Crux")
        gLabel.text = "0"
        gLabel.fontSize = 140
        gLabel.position = CGPoint(x: 0, y: -gLabel.frame.height/2 + 4)
        gIcon.addChild(gLabel)
        
        icons.position.y = 30
        cam.addChild(icons)
        
        
        
        w = SKSpriteNode(imageNamed: "wood0").px()
        w.size = CGSize(width: 72, height: 81)
        w.position.y = height - 100
        w.position.x = -width + 100
        cam.addChild(w)
        
        let defaults = UserDefaults.standard
        
        wl = SKLabelNode(fontNamed: "Coder's Crux")
        wl.text = String((defaults.value(forKey: "wooden") ?? 0) as! Int)
        wl.fontSize = 110
        wl.position.x = w.frame.width/2 + wl.frame.width/2 + 25
        wl.position.y = -wl.frame.height/2 + 2
        wl.fontColor = UIColor(red: 84/255, green: 84/255, blue: 84/255, alpha: 1)
        w.addChild(wl)
        
        b = SKSpriteNode(imageNamed: "bronze0").px()
        b.size = CGSize(width: 72, height: 81)
        b.position.y = w.frame.minY - 70
        b.position.x = -width + 100
        cam.addChild(b)
        
        bl = SKLabelNode(fontNamed: "Coder's Crux")
        bl.text = String((defaults.value(forKey: "bronze") ?? 0) as! Int)
        bl.fontSize = 110
        bl.position.x = b.frame.width/2 + bl.frame.width/2 + 25
        bl.position.y = -bl.frame.height/2 + 2
        bl.fontColor = UIColor(red: 84/255, green: 84/255, blue: 84/255, alpha: 1)
        b.addChild(bl)
        
        g = SKSpriteNode(imageNamed: "golden0").px()
        g.size = CGSize(width: 72, height: 81)
        g.position.y = b.frame.minY - 70
        g.position.x = -width + 100
        cam.addChild(g)
        
        gl = SKLabelNode(fontNamed: "Coder's Crux")
        gl.text = String((defaults.value(forKey: "golden") ?? 0) as! Int) 
        gl.fontSize = 110
        gl.position.x = g.frame.width/2 + gl.frame.width/2 + 25
        gl.position.y = -gl.frame.height/2 + 2
        gl.fontColor = UIColor(red: 84/255, green: 84/255, blue: 84/255, alpha: 1)
        g.addChild(gl)
        
        menuBtn = Button(text: "BACK TO MENU", color: .gray, position: CGPoint(x: 0, y: -500))
        menuBtn.sprite.alpha = 0
        cam.addChild(menuBtn.sprite)
        
        advBtn = Button(text: "CONTINUE", color: .blue, position: CGPoint(x: 0, y: menuBtn.sprite.frame.maxY + 100))
        advBtn.sprite.alpha = 0
        cam.addChild(advBtn.sprite)
    }
    
    func set(score: Int) {
        gameScore.text = String(score)
        gameScore.position = CGPoint(x: -width + gameScore.frame.width/2 + 60, y: height - gameScore.frame.height/2 - 100)
        ptsScore.text = "\(score)"
        ptsScore.position.x = lblScore.frame.maxX + ptsScore.frame.width/2 + 15
        mScore.position = CGPoint(x: gameOver.position.x - ptsScore.frame.width/2, y: gameOver.position.y - 100)
    }
    
    func plusCoin(coin: Currency) {
        switch coin {
        case .wood:
            let curr = Int(wLabel.text!)!
            wLabel.text = String(curr + 1)
        case .bronze:
            let curr = Int(bLabel.text!)!
            bLabel.text = String(curr + 1)
        case .golden:
            let curr = Int(gLabel.text!)!
            gLabel.text = String(curr + 1)
        }
    }
    
    private func setAnimations() {
        var smokeTextures: [SKTexture] = []
        for i in 0...3 {
            smokeTextures.append(SKTexture(imageNamed: "smoke\(i)").px())
        }
        smokeAnim = SKAction.animate(with: smokeTextures, timePerFrame: 0.12)
        
        var doorTextures: [SKTexture] = []
        for i in 1...6 {
            doorTextures.append(SKTexture(imageNamed: "door\(i)").px())
        }
        doorAnim = SKAction.animate(with: doorTextures, timePerFrame: 0.07)
        doorAnim.timingMode = SKActionTimingMode.easeOut
        
        pauseTexture = SKTexture(imageNamed: "pause").px()
        playTexture = SKTexture(imageNamed: "continue").px()
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
    
    
    private func fade(node: SKNode, to value: CGFloat, duration: TimeInterval, _ shadow: Bool) {
        let fade = SKAction.fadeAlpha(to: value, duration: duration)
        fade.timingMode = SKActionTimingMode.easeOut
        fade.speed = 4
        
        if shadow {
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
    func px() -> SKSpriteNode {
        let node = self as! SKSpriteNode
        node.texture?.filteringMode = .nearest
        return node
    }
}

extension SKTexture {
    func px() -> SKTexture {
        self.filteringMode = .nearest
        return self
    }
}

extension NSMutableAttributedString{
    func setColorForText(_ textToFind: String, with color: UIColor) {
        let range = self.mutableString.range(of: textToFind, options: .caseInsensitive)
        if range.location != NSNotFound {
            addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: range)
        }
    }
}
