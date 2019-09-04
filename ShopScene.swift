//
//  ShopScene.swift
//  Jump
//
//  Created by debavlad on 9/3/19.
//  Copyright © 2019 Vladislav Deba. All rights reserved.
//

import Foundation
import GameplayKit

class ShopScene: SKScene {
    private var fade, bg, leftArrow, rightArrow, skin: SKSpriteNode!
    private var naming: SKLabelNode!
    private var triggeredNode: SKNode!
    private var pages: [SKSpriteNode]!
    
    private var skins: [Skin]!
    private var curIndex: Int = 0
    
    override func didMove(to view: SKView) {
        skins = [Skin(name: "FARMER", textureName: "farmer"),
                 Skin(name: "BUSINESSMAN", textureName: "bman")]
        
        scaleMode = .aspectFill
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        bg = SKSpriteNode(imageNamed: "shop-bg").pixelated()
        bg.size = frame.size
        addChild(bg)
        
        let panel = SKNode()
        panel.position.y = 40
        
        skin = SKSpriteNode(imageNamed: "\(GameScene.skinName)-jump0").pixelated()
        skin.zPosition = 2
        skin.setScale(3.5)
        panel.addChild(skin)
        
        let shadow = SKSpriteNode(imageNamed: "shadow").pixelated()
        shadow.zPosition = 1
        shadow.setScale(8)
        shadow.position.y = -90
        panel.addChild(shadow)
        
        pages = []
        
        let pageCounter = SKNode()
        for i in 0..<skins.count {
            let page = SKSpriteNode(imageNamed: "page0").pixelated()
            if i == 0 {
                page.texture = SKTexture(imageNamed: "page1").pixelated()
            }
            page.setScale(4)
            page.position.x = 50 * CGFloat(i)
//            pages[i] = page
            pages.insert(page, at: i)
            pageCounter.addChild(page)
        }
        pageCounter.position.y = -205
        pageCounter.position.x = -25
        pageCounter.zPosition = 2
        panel.addChild(pageCounter)
        
        leftArrow = SKSpriteNode(imageNamed: "dis-arrow0").pixelated()
        leftArrow.zPosition = 2
        leftArrow.position.x = -150
        leftArrow.yScale = 6
        leftArrow.xScale = -6
        panel.addChild(leftArrow)
        
        rightArrow = SKSpriteNode(imageNamed: "act-arrow0").pixelated()
        rightArrow.zPosition = 2
        rightArrow.position.x = 150
        rightArrow.setScale(6)
        panel.addChild(rightArrow)
        
        naming = SKLabelNode(fontNamed: "Coder's Crux")
        naming.text = "BUSINESSMAN"
        naming.fontSize = 70
        naming.position.y = -170
        naming.zPosition = 2
        panel.addChild(naming)
        
        fade = SKSpriteNode(color: .black, size: frame.size)
        fade.alpha = 1
        fade.zPosition = 5
        addChild(fade)
        
        addChild(panel)
        loadSkin(skin: skins[curIndex])
        
        fade.run(SKAction.fadeOut(withDuration: 0.3))
    }
    
    func loadSkin(skin: Skin) {
        let textureName = "\(skin.textureName)-jump0"
        self.skin.texture = SKTexture(imageNamed: textureName).pixelated()
        self.naming.text = skin.name
        
        for i in 0..<pages.count {
            if i == curIndex {
                pages[i].texture = SKTexture(imageNamed: "page1").pixelated()
            } else {
                pages[i].texture = SKTexture(imageNamed: "page0").pixelated()
            }
        }
        
        if curIndex == 0 {
            leftArrow.texture = SKTexture(imageNamed: "dis-arrow0").pixelated()
        } else {
            leftArrow.texture = SKTexture(imageNamed: "act-arrow0").pixelated()
        }
        
        if curIndex == skins.count - 1 {
            rightArrow.texture = SKTexture(imageNamed: "dis-arrow0").pixelated()
        } else {
            rightArrow.texture = SKTexture(imageNamed: "act-arrow0").pixelated()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let node = atPoint(touch.location(in: self))
        
//        if node == rightArrow && curIndex != skins.count - 1 {
        if touch.location(in: self).x > 0 && curIndex != skins.count - 1 {
            rightArrow.texture = SKTexture(imageNamed: "act-arrow1").pixelated()
            triggeredNode = rightArrow
//        } else if node == leftArrow && curIndex != 0 {
        } else if touch.location(in: self).x <= 0 && curIndex != 0 {
            leftArrow.texture = SKTexture(imageNamed: "act-arrow1").pixelated()
            triggeredNode = leftArrow
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if triggeredNode == rightArrow {
            rightArrow.texture = SKTexture(imageNamed: "act-arrow0").pixelated()
            curIndex += 1
        } else if triggeredNode == leftArrow {
            leftArrow.texture = SKTexture(imageNamed: "act-arrow0").pixelated()
            curIndex -= 1
        }
        
        loadSkin(skin: skins[curIndex])
        triggeredNode = nil
    }
}
