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
    private var labels: [SKLabelNode]!
    private var particles: [SKEmitterNode]!
    private var width, height: CGFloat
    private(set) var menuBtn, advertBtn: Button!
    private(set) var gameOver, gameScore, menuScore, ptsScore, lblScore, wLabel, bLabel, gLabel, wl, bl, gl, bottomStage, topStage, continueLbl: SKLabelNode!
    private(set) var house, door, line, slider, pauseBtn, darken, red, hpBorder, hpStripe, mScore, wIcon, bIcon, gIcon, w, b, g, stageBorder, stageLine: SKSpriteNode!
    private(set) var pauseTexture, playTexture: SKTexture!
    private(set) var smokeAnim, doorAnim: SKAction!
    private var score: Int = 0
    
    init(_ scene: SKScene, _ world: SKNode) {
        self.scene = scene
        width = UIScreen.main.bounds.width
        height = UIScreen.main.bounds.height
        labels = []
        particles = []
        setAnimations()
        setScene(world)
    }
    
    
    func finishMenu(visible: Bool) {
        if visible {
            ptsScore.text = "\(score)"
            ptsScore.position.x = lblScore.frame.maxX + ptsScore.frame.width/2 + 15
            mScore.position = CGPoint(x: gameOver.position.x - ptsScore.frame.width/2, y: gameOver.position.y - 100)
            hide(line, hpBorder, pauseBtn, stageBorder)
            for (icon, label) in [(wIcon, wLabel), (bIcon, bLabel), (gIcon, gLabel)] {
                icon!.position.x = -label!.frame.width/2
                label!.position.x = icon!.frame.maxX + label!.frame.width + 30
            }
            
            /* If watched an advertisement */
//            advertBtn.sprite.isHidden = true
//            menuBtn.sprite.position = advertBtn.sprite.position
//            show(line)
            //
            
            show(advertBtn.node, menuBtn.node, wIcon, bIcon, gIcon, gameOver, mScore)
            fade(0.7, 1, [darken])
            fade(0.4, 0.6, [red])
        } else {
            fade(0, 2, [advertBtn.node, menuBtn.node, wIcon, bIcon, gIcon, gameOver, mScore, darken, red])
            show(line, hpBorder, pauseBtn, stageBorder)
        }
    }
    
    func setScore(_ score: Int, _ stage: Stage) {
        self.score = score
        gameScore.text = String(score)
        gameScore.position = CGPoint(x: -width + gameScore.frame.width/2 + 60, y: height - gameScore.frame.height/2 - 100)
        
        if stage.current < 3 {
            let amount = CGFloat(score - stage.current*100)
            stageLine.size.height = stageBorder.size.height/100*amount
        } else {
            hide(stageBorder)
        }
    }
    
    func collectCoin(_ currency: Currency) {
        let label: SKLabelNode
        switch currency {
        case .wood:
            label = wLabel
        case .bronze:
            label = bLabel
        case .golden:
            label = gLabel
        }
        label.text = String(Int(label.text!)! + 1)
    }
    
    
    func createEmitter(_ parent: SKNode, _ filename: String, _ position: CGPoint) {
        let emitter = SKEmitterNode(fileNamed: filename)!
        emitter.name = String()
        emitter.position = position
        emitter.zPosition = 3
        emitter.particleZPosition = 3
        
        parent.addChild(emitter)
        particles.append(emitter)
    }
    
    func createLabel(_ parent: SKNode, _ position: CGPoint) {
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
        labels.append(label)
        label.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 60))
        let rotate = CGFloat.random(in: -0.0005...0.0005)
        label.physicsBody?.applyAngularImpulse(rotate)
    }
    
    func removeEmitters(_ minY: CGFloat) {
        if particles.count > 0 {
            if (particles.first!.frame.maxY < minY) {
                particles.first!.removeFromParent()
                particles.removeFirst()
            }
        }
    }
    
    func removeLabels(_ minY: CGFloat) {
        if labels.count > 0 {
            if labels.first!.frame.maxY < minY {
                labels.first!.removeFromParent()
                labels.removeFirst()
            }
        }
//        if labels.count > 0 {
//            labels.filter({ (node) -> Bool in
//                return node.frame.maxY < minY
//            }).forEach { (label) in
//                labels.remove(label)
//                label.removeFromParent()
//            }
//        }
    }
    
    
    private func fade(_ alpha: CGFloat, _ duration: TimeInterval, _ nodes: [SKNode]) {
        let a = SKAction.fadeAlpha(to: alpha, duration: duration)
        a.timingMode = SKActionTimingMode.easeOut
        a.speed = 4

        for node in nodes {
            node.run(a)
        }
    }
    
    func show(_ nodes: SKNode...) {
        fade(1.0, 2, nodes)
    }

    func hide(_ nodes: SKNode...) {
        fade(0, 0.6, nodes)
    }
    
    
    private func setScene(_ world: SKNode) {
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
        
        
        let player = SKSpriteNode(imageNamed: "\(Skins[GameScene.skinIndex].name)-sit0").px()
        player.name = "Character"
        player.size = CGSize(width: 132, height: 140)
        player.position = CGPoint(x: -160, y: GameScene.restarted ? -200 : -250)
        player.zPosition = 10
        
        // STAGE STATUS BAR
        stageBorder = SKSpriteNode(imageNamed: "stage-line").px()
        stageBorder.size = CGSize(width: 16, height: 608)
        stageBorder.position.x = -width + 80
        stageBorder.zPosition = 20
        stageBorder.alpha = 0
        cam.addChild(stageBorder)
        
        stageLine = SKSpriteNode(imageNamed: "stage-fill").px()
        stageLine.size.width = 8
        stageLine.size.height = 0
        stageLine.anchorPoint.y = 0
        stageLine.position.y = -stageBorder.size.height/2
        stageLine.zPosition = 20
        stageBorder.addChild(stageLine)
        
        bottomStage = SKLabelNode(fontNamed: "pixelFJ8pt1")
        bottomStage.fontSize = 50
        bottomStage.text = "0"
        bottomStage.position.y = -stageBorder.frame.height/2 - bottomStage.frame.height - 15
        bottomStage.fontColor = UIColor(red: 84/255, green: 84/255, blue: 84/255, alpha: 1)
        bottomStage.zPosition = 20
        stageBorder.addChild(bottomStage)
        
        topStage = SKLabelNode(fontNamed: "pixelFJ8pt1")
        topStage.fontSize = 50
        topStage.text = "1"
        topStage.position.y = stageBorder.frame.height/2 + 15
        topStage.fontColor = UIColor(red: 84/255, green: 84/255, blue: 84/255, alpha: 1)
        topStage.zPosition = 20
        stageBorder.addChild(topStage)
        
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
        
        menuScore = SKLabelNode(fontNamed: "pixelFJ8pt1")
        
        mScore = SKSpriteNode()
        mScore.zPosition = 21
        mScore.alpha = 0
        mScore.position = CGPoint(x: gameOver.position.x, y: gameOver.position.y - 100)
        
        lblScore = SKLabelNode(fontNamed: "pixelFJ8pt1")
        lblScore.text = "SCORE:"
        lblScore.fontSize = 55
        mScore.addChild(lblScore)
        
        continueLbl = SKLabelNode(fontNamed: "pixelFJ8pt1")
        continueLbl.text = "TIME TO CONTINUE!"
        continueLbl.fontSize = 45
        continueLbl.position.y = -490
        continueLbl.zPosition = 21
        continueLbl.isHidden = true
        cam.addChild(continueLbl)
        
        ptsScore = SKLabelNode(fontNamed: "pixelFJ8pt1")
        ptsScore.text = "0"
        ptsScore.fontSize = 55
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
        
        let icons = SKNode()
        
        wIcon = SKSpriteNode(imageNamed: "wood0").px()
        wIcon.size = CGSize(width: 90, height: 99)
        wIcon.position.y = 180 // +50
        wIcon.zPosition = 21
        wIcon.alpha = 0
        icons.addChild(wIcon)

        wLabel = SKLabelNode(fontNamed: "pixelFJ8pt1")
        wLabel.text = "0"
        wLabel.fontSize = 76
        wLabel.position = CGPoint(x: 0, y: -wLabel.frame.height/2 + 4)
        wIcon.addChild(wLabel)
        
        bIcon = SKSpriteNode(imageNamed: "bronze0").px()
        bIcon.size = CGSize(width: 90, height: 99)
        bIcon.position.y = 30
        bIcon.zPosition = 21
        bIcon.alpha = 0
        icons.addChild(bIcon)
        
        bLabel = SKLabelNode(fontNamed: "pixelFJ8pt1")
        bLabel.text = "0"
        bLabel.fontSize = 76
        bLabel.position = CGPoint(x: 0, y: -bLabel.frame.height/2 + 4)
        bIcon.addChild(bLabel)
        
        gIcon = SKSpriteNode(imageNamed: "golden0").px()
        gIcon.size = CGSize(width: 90, height: 99)
        gIcon.position.y = -120
        gIcon.zPosition = 21
        gIcon.alpha = 0
        icons.addChild(gIcon)
        
        gLabel = SKLabelNode(fontNamed: "pixelFJ8pt1")
        gLabel.text = "0"
        gLabel.fontSize = 76
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
        
        wl = SKLabelNode(fontNamed: "pixelFJ8pt1")
        wl.text = String((defaults.value(forKey: "wooden") ?? 0) as! Int)
        wl.fontSize = 66
        wl.position.x = w.frame.width/2 + wl.frame.width/2 + 25
        wl.position.y = -wl.frame.height/2 + 2
        wl.fontColor = UIColor(red: 84/255, green: 84/255, blue: 84/255, alpha: 1)
        w.addChild(wl)
        
        b = SKSpriteNode(imageNamed: "bronze0").px()
        b.size = CGSize(width: 72, height: 81)
        b.position.y = w.frame.minY - 70
        b.position.x = -width + 100
        cam.addChild(b)
        
        bl = SKLabelNode(fontNamed: "pixelFJ8pt1")
        bl.text = String((defaults.value(forKey: "bronze") ?? 0) as! Int)
        bl.fontSize = 66
        bl.position.x = b.frame.width/2 + bl.frame.width/2 + 25
        bl.position.y = -bl.frame.height/2 + 2
        bl.fontColor = UIColor(red: 84/255, green: 84/255, blue: 84/255, alpha: 1)
        b.addChild(bl)
        
        g = SKSpriteNode(imageNamed: "golden0").px()
        g.size = CGSize(width: 72, height: 81)
        g.position.y = b.frame.minY - 70
        g.position.x = -width + 100
        cam.addChild(g)
        
        gl = SKLabelNode(fontNamed: "pixelFJ8pt1")
        gl.text = String((defaults.value(forKey: "golden") ?? 0) as! Int)
        gl.fontSize = 66
        gl.position.x = g.frame.width/2 + gl.frame.width/2 + 25
        gl.position.y = -gl.frame.height/2 + 2
        gl.fontColor = UIColor(red: 84/255, green: 84/255, blue: 84/255, alpha: 1)
        g.addChild(gl)
        
        menuBtn = Button("BACK TO MENU", .gray, CGPoint(x: 0, y: -500))
        menuBtn.node.alpha = 0
        cam.addChild(menuBtn.node)
        
        advertBtn = Button("CONTINUE", .blue, CGPoint(x: 0, y: menuBtn.node.frame.maxY + 100))
        advertBtn.node.alpha = 0
        cam.addChild(advertBtn.node)
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
