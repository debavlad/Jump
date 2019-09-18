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
}

class ShopScene: SKScene {
    var leftPlayer = AVAudioPlayer(), rightPlayer = AVAudioPlayer()
    
    private var fade, bg, leftArrow, rightArrow, skinSprite: SKSpriteNode!
    private var skinTitle: SKLabelNode!
    private var triggeredNode: SKNode!
    private var pages: [SKSpriteNode] = []
    private var cam: Camera!
    
    private var skins: [Skin]!
    private var curIndex: Int = 0
    
    override func didMove(to view: SKView) {
        do {
            leftPlayer = try AVAudioPlayer(contentsOf: Bundle.main.url(forResource: "push-down", withExtension: "wav")!)
            rightPlayer = try AVAudioPlayer(contentsOf: Bundle.main.url(forResource: "push-down", withExtension: "wav")!)
            leftPlayer.volume = 0.2
            rightPlayer.volume = 0.2
            leftPlayer.prepareToPlay()
            rightPlayer.prepareToPlay()
            let session = AVAudioSession()
            do {
                try session.setCategory(.playback)
            } catch {
                print(error.localizedDescription)
            }
            
        } catch {
            print(error.localizedDescription)
        }
        setScene()
    }
    
    private func setScene() {
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        bg = SKSpriteNode(imageNamed: "shop-bg").pixelated()
        bg.size = frame.size
        addChild(bg)
        
        cam = Camera(scene: self)
        cam.node.setScale(0.8)
        
        skinSprite = SKSpriteNode(imageNamed: "\(GameScene.skinName)-jump0").pixelated()
        skinSprite.zPosition = 2
        skinSprite.setScale(3)
        skinSprite.xScale = -3
        skinSprite.position = CGPoint(x: 0, y: -230)
        addChild(skinSprite)
        
        leftArrow = SKSpriteNode(imageNamed: "disabled-arrow").pixelated()
        leftArrow.zPosition = 2
        leftArrow.position = CGPoint(x: -250, y: -300)
        leftArrow.yScale = 6
        leftArrow.xScale = -6
        cam.node.addChild(leftArrow)
        
        rightArrow = SKSpriteNode(imageNamed: "arrow").pixelated()
        rightArrow.zPosition = 2
        rightArrow.position = CGPoint(x: 250, y: -300)
        rightArrow.setScale(6)
        cam.node.addChild(rightArrow)
        
        skinTitle = SKLabelNode(fontNamed: "Coder's Crux")
        skinTitle.fontSize = 70
        skinTitle.position.y = 60
        skinTitle.zPosition = 2
        addChild(skinTitle)
        
        fade = SKSpriteNode(color: .black, size: frame.size)
        fade.zPosition = 5
        addChild(fade)
        
        skins = [
            Skin(title: "Farmer", texture: SKTexture(imageNamed: "farmer-sit0").pixelated()),
            Skin(title: "Zombie", texture: SKTexture(imageNamed: "zombie-sit0").pixelated()),
            Skin(title: "Businessman", texture: SKTexture(imageNamed: "bman-sit0").pixelated())
        ]
        
        let pageCounter = SKNode()
        pageCounter.position = CGPoint(x: -50, y: 30)
        pageCounter.zPosition = 2
        for i in 0..<skins.count {
            let page = SKSpriteNode(imageNamed: "inactive-page").pixelated()
            page.position.x = 50 * CGFloat(i)
            page.setScale(4)
            
            pages.insert(page, at: i)
            pageCounter.addChild(page)
        }
        
        addChild(pageCounter)
        loadSkin(skin: skins[curIndex])
        
        let fadeOut = SKAction.fadeOut(withDuration: 0.3)
        fadeOut.timingMode = SKActionTimingMode.easeOut
        fade.run(fadeOut)
    }
    
    enum ButtonPlayer {
        case left
        case right
    }
    
    func playSound(side: ButtonPlayer) {
        switch side {
        case .left:
            leftPlayer.play()
        case .right:
            rightPlayer.play()
        }
    }
    
    func loadSkin(skin: Skin) {
        self.skinSprite.texture = skin.texture
        self.skinTitle.text = skin.title
        
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
//        let node = atPoint(touch.location(in: self))
        
        if touch.location(in: self).x > 0 && curIndex != skins.count - 1 {
            playSound(side: .right)
            if triggeredNode == leftArrow {
                leftArrow.yScale = 6
            }
            rightArrow.yScale = -6
            triggeredNode = rightArrow
        } else if touch.location(in: self).x <= 0 && curIndex != 0 {
            playSound(side: .left)
            if triggeredNode == rightArrow {
                rightArrow.yScale = 6
            }
            leftArrow.yScale = -6
            triggeredNode = leftArrow
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if triggeredNode == rightArrow {
            rightArrow.yScale = 6
            curIndex += 1
        } else if triggeredNode == leftArrow {
            leftArrow.yScale = 6
            curIndex -= 1
        }
        
        loadSkin(skin: skins[curIndex])
        triggeredNode = nil
    }
    
    override func update(_ currentTime: TimeInterval) {
        cam.shake(amplitude: 1, amount: 5, step: 0, duration: 2)
    }
}
