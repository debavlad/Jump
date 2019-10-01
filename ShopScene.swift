//
//  ShopScene.swift
//  Jump
//
//  Created by debavlad on 9/3/19.
//  Copyright © 2019 Vladislav Deba. All rights reserved.
//

import Foundation
import GameplayKit
import AVFoundation

struct Skin {
    var title: String
    var texture: SKTexture
    var name: String
}

class ShopScene: SKScene {
//    var player1 = AVAudioPlayer(), player2 = AVAudioPlayer()
    
    private var fade, bg, leftArrow, rightArrow, skinSprite: SKSpriteNode!
    private var skinTitle: SKLabelNode!
    private var triggeredNode: SKNode!
    private var pages: [SKSpriteNode] = []
    private var btn: Button!
    private var cam: Camera!
    
    private var skins: [Skin]!
    private var curIndex: Int!
    
    override func didMove(to view: SKView) {
//        do {
//            player1 = try AVAudioPlayer(contentsOf: Bundle.main.url(forResource: "push-down", withExtension: "wav")!)
//            player2 = try AVAudioPlayer(contentsOf: Bundle.main.url(forResource: "push-down", withExtension: "wav")!)
//            player1.volume = 0.2
//            player2.volume = 0.2
//            player1.prepareToPlay()
//            player2.prepareToPlay()
//            let session = AVAudioSession()
//            do {
//                try session.setCategory(.playback)
//            } catch {
//                print(error.localizedDescription)
//            }
//
//        } catch {
//            print(error.localizedDescription)
//        }
        setScene()
    }
    
    func touchIsAboveTheButton(point: CGPoint) -> Bool {
        return point.y > leftArrow.position.y - 100 && point.y > rightArrow.position.y - 100
    }
    
    private func setScene() {
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        bg = SKSpriteNode(imageNamed: "shop-bg").pixelated()
        bg.size = frame.size
        addChild(bg)
        
        cam = Camera(scene: self)
        cam.node.setScale(0.7)
        
        skinSprite = SKSpriteNode(imageNamed: "\(GameScene.skinName)-jump0").pixelated()
        skinSprite.zPosition = 2
        skinSprite.setScale(3)
        skinSprite.xScale = -3
        skinSprite.position = CGPoint(x: 0, y: -230 + 138)
        addChild(skinSprite)
        
        leftArrow = SKSpriteNode(imageNamed: "disabled-arrow").pixelated()
        leftArrow.zPosition = 2
        leftArrow.position = CGPoint(x: -250, y: -300 + 138)
        leftArrow.yScale = 7
        leftArrow.xScale = -7
        cam.node.addChild(leftArrow)
        
        rightArrow = SKSpriteNode(imageNamed: "arrow").pixelated()
        rightArrow.zPosition = 2
        rightArrow.position = CGPoint(x: 250, y: -300 + 138)
        rightArrow.setScale(7)
        cam.node.addChild(rightArrow)
        
        skinTitle = SKLabelNode(fontNamed: "Coder's Crux")
        skinTitle.fontSize = 70
        skinTitle.position.y = 60 + 138
        skinTitle.zPosition = 2
        addChild(skinTitle)
        
        fade = SKSpriteNode(color: .black, size: frame.size)
        fade.zPosition = 30
        addChild(fade)
        
        skins = [
            Skin(title: "Farmer", texture: SKTexture(imageNamed: "farmer-sit0").pixelated(), name: "farmer"),
            Skin(title: "Zombie", texture: SKTexture(imageNamed: "zombie-sit0").pixelated(), name: "zombie"),
            Skin(title: "Businessman", texture: SKTexture(imageNamed: "bman-sit0").pixelated(), name: "bman")
        ]
        
        let pageCounter = SKNode()
        pageCounter.position = CGPoint(x: -50, y: 30 + 138)
        pageCounter.zPosition = 2
        for i in 0..<skins.count {
            let page = SKSpriteNode(imageNamed: "inactive-page").pixelated()
            page.position.x = 50 * CGFloat(i)
            page.setScale(4)
            
            pages.insert(page, at: i)
            pageCounter.addChild(page)
        }
        
        addChild(pageCounter)
        for i in 0..<skins.count {
            if skins[i].name == GameScene.skinName {
                curIndex = i
                loadSkin(skin: skins[i])
                break
            }
        }
        
        let fadeOut = SKAction.fadeOut(withDuration: 0.3)
        fadeOut.timingMode = SKActionTimingMode.easeOut
        fade.run(fadeOut)
        
        btn = Button(text: "BACK TO MENU", position: CGPoint(x: 0, y: -480))
        cam.node.addChild(btn.sprite)
    }
    
    enum ButtonPlayer {
        case left
        case right
    }
    
    func playSound() {
//        if !player1.isPlaying {
//            player1.play()
//        } else {
//            player2.play()
//        }
    }
    
    func loadSkin(skin: Skin) {
        self.skinSprite.texture = skin.texture
        self.skinTitle.text = skin.title
        GameScene.skinName = skin.name
        
        for i in 0..<pages.count {
            if i == curIndex {
                pages[i].texture = SKTexture(imageNamed: "current-page").pixelated()
            } else {
                pages[i].texture = SKTexture(imageNamed: "inactive-page").pixelated()
            }
        }
        
        if curIndex == 0 {
            leftArrow.texture = SKTexture(imageNamed: "disabled-arrow").pixelated()
        } else {
            leftArrow.texture = SKTexture(imageNamed: "arrow").pixelated()
        }
        
        if curIndex == skins.count - 1 {
            rightArrow.texture = SKTexture(imageNamed: "disabled-arrow").pixelated()
        } else {
            rightArrow.texture = SKTexture(imageNamed: "arrow").pixelated()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let node = atPoint(touch.location(in: self))
        
        if node == btn.sprite || node == btn.label {
            playSound()
            btn.state(pushed: true)
            triggeredNode = btn.sprite
            restart()
        } else {
            if touch.location(in: self).x > 0 && touchIsAboveTheButton(point: touch.location(in: self)) && curIndex != skins.count - 1 {
                playSound()
                if triggeredNode == leftArrow {
                    leftArrow.yScale = 7
                }
                rightArrow.yScale = -7
                triggeredNode = rightArrow
            } else if touch.location(in: self).x <= 0 && touchIsAboveTheButton(point: touch.location(in: self)) && curIndex != 0 {
                playSound()
                if triggeredNode == rightArrow {
                    rightArrow.yScale = 7
                }
                leftArrow.yScale = -7
                triggeredNode = leftArrow
            }
        }
//        } else if touch.location(in: self).x > 0 && touchIsAboveTheButton(point: touch.location(in: self)) && curIndex != skins.count - 1 {
//            playSound()
//            if triggeredNode == leftArrow {
//                leftArrow.yScale = 6
//            }
//            rightArrow.yScale = -6
//            triggeredNode = rightArrow
//        } else if touch.location(in: self).x <= 0 && touchIsAboveTheButton(point: touch.location(in: self)) && curIndex != 0 {
//            playSound()
//            if triggeredNode == rightArrow {
//                rightArrow.yScale = 6
//            }
//            leftArrow.yScale = -6
//            triggeredNode = leftArrow
//        }
    }
    
    private func restart() {
        let wait = SKAction.wait(forDuration: 0.4)
        let physics = SKAction.run {
//            let scale = SKAction.scale(to: 1.0, duration: 0.4)
//            scale.timingMode = SKActionTimingMode.easeIn
//            scale.speed = 0.5
//            self.cam.node.run(scale)
            self.fade.run(SKAction.fadeIn(withDuration: 0.4))
        }
        let act = SKAction.run {
            GameScene.restarted = true
            let scene = GameScene(size: self.frame.size)
            scene.scaleMode = SKSceneScaleMode.aspectFill
            self.view!.presentScene(scene)
            self.removeAllChildren()
        }
        run(SKAction.sequence([SKAction.group([wait, physics]), act ]))
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if triggeredNode == btn.sprite {
            btn.state(pushed: false)
        } else if triggeredNode == rightArrow {
            rightArrow.yScale = 7
            curIndex += 1
        } else if triggeredNode == leftArrow {
            leftArrow.yScale = 7
            curIndex -= 1
        }
        
        loadSkin(skin: skins[curIndex])
        triggeredNode = nil
    }
    
    override func update(_ currentTime: TimeInterval) {
        cam.shake(amplitude: 0.8, amount: 5, step: 0, duration: 2)
    }
}
