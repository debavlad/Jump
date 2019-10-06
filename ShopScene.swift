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

struct Skin : Hashable {
    var title, name: String
    var texture: SKTexture
    var price: Int
    var currency: Currency
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
        hasher.combine(name)
        hasher.combine(texture)
        hasher.combine(price)
        hasher.combine(currency)
    }
    
    static func == (lhs: Skin, rhs: Skin) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}

class ShopScene: SKScene {
    let defaults = UserDefaults.standard
    var wooden, bronze, golden: Int!
    
    let height = UIScreen.main.bounds.height
    private var fade, leftArrow, rightArrow, skinSprite: SKSpriteNode!
    private var skinTitle: SKLabelNode!
    private var backBtn, actBtn: Button!
    private var triggeredNode: SKNode!
    private var cam: Camera!
    
    static var skins = [
        Skin(title: "Farmer", name: "farmer", texture: SKTexture(imageNamed: "farmer-sit0").px(), price: 80, currency: .wood),
        Skin(title: "Zombie", name: "zombie", texture: SKTexture(imageNamed: "zombie-sit0").px(), price: 60, currency: .bronze),
        Skin(title: "Businessman", name: "bman", texture: SKTexture(imageNamed: "bman-sit0").px(), price: 20, currency: .golden)
    ]
    
    private var pages: [SKSpriteNode]!
//    private var skins: [Skin]!
    private var index: Int!
    
    override func didMove(to view: SKView) {
        wooden = defaults.value(forKey: "wooden") as? Int
        bronze = defaults.value(forKey: "bronze") as? Int
        golden = defaults.value(forKey: "golden") as? Int
        
        pages = []
        setScene()
    }
    
    func setScene() {
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        let bg = SKSpriteNode(imageNamed: "shop-bg").px()
        bg.position.y = 110
        bg.size = frame.size
        addChild(bg)
        
        cam = Camera(scene: self)
        cam.node.setScale(0.7)
        
        skinSprite = SKSpriteNode(imageNamed: "\(GameScene.currentSkin!.name)-jump0").px()
        skinSprite.position = CGPoint(x: 0, y: bg.position.y - 90)
        skinSprite.zPosition = 2
        skinSprite.xScale = -3
        skinSprite.yScale = 3
        addChild(skinSprite)
        
        leftArrow = SKSpriteNode(imageNamed: "disabled-arrow").px()
        leftArrow.position = CGPoint(x: -250, y: skinSprite.position.y)
        leftArrow.zPosition = 2
        leftArrow.xScale = -7
        leftArrow.yScale = 7
        cam.node.addChild(leftArrow)
        
        rightArrow = SKSpriteNode(imageNamed: "arrow").px()
        rightArrow.position = CGPoint(x: 250, y: skinSprite.position.y)
        rightArrow.zPosition = 2
        rightArrow.setScale(7)
        cam.node.addChild(rightArrow)
        
        skinTitle = SKLabelNode(fontNamed: "Coder's Crux")
        skinTitle.position.y = bg.position.y + 200
        skinTitle.zPosition = 2
        skinTitle.fontSize = 70
        addChild(skinTitle)
        
        fade = SKSpriteNode(color: .black, size: frame.size)
        fade.zPosition = 30
        addChild(fade)
        
        backBtn = Button(text: "BACK TO MENU", color: .gray, position: CGPoint(x: 0, y: -height + 150))
        cam.node.addChild(backBtn.sprite)
        
        actBtn = Button(price: 90, type: .wood, y: backBtn.sprite.position.y + 180)
        cam.node.addChild(actBtn.sprite)
        
//        skins = [
//            Skin(title: "Farmer", name: "farmer", texture: SKTexture(imageNamed: "farmer-sit0").px(), owned: true, set: true, price: 0, currency: .wood),
//            Skin(title: "Zombie", name: "zombie", texture: SKTexture(imageNamed: "zombie-sit0").px(), owned: false, set: false, price: 40, currency: .wood),
//            Skin(title: "Businessman", name: "bman", texture: SKTexture(imageNamed: "bman-sit0").px(), owned: false, set: false, price: 20, currency: .bronze)
//        ]
        
        let pageCounter = SKNode()
        pageCounter.position = CGPoint(x: -50, y: bg.position.y + 170)
        pageCounter.zPosition = 2
        for i in 0..<ShopScene.skins.count {
            let page = SKSpriteNode(imageNamed: "inactive-page").px()
            page.position.x = 50 * CGFloat(i)
            page.setScale(4)
            pages.insert(page, at: i)
            pageCounter.addChild(page)
        }
        addChild(pageCounter)
        
        for i in 0..<ShopScene.skins.count {
            if ShopScene.skins[i].name == GameScene.currentSkin!.name {
                index = i
                loadSkin(skin: ShopScene.skins[i])
                loadButtonData(for: ShopScene.skins[index])
                break
            }
        }
        
        let fadeOut = SKAction.fadeOut(withDuration: 0.3)
        fadeOut.timingMode = SKActionTimingMode.easeOut
        fade.run(fadeOut)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let node = atPoint(touch.location(in: self))
        
        if node == actBtn.sprite || node == actBtn.label {
            actBtn.push()
            triggeredNode = actBtn.sprite
        }
        else if node == backBtn.sprite || node == backBtn.label {
            backBtn.push()
            triggeredNode = backBtn.sprite
            backToMain()
        } else {
            let loc = touch.location(in: self)
            if loc.y > skinSprite.frame.minY - 100 {
                if loc.x > 0 && index != ShopScene.skins.count - 1 {
                    if triggeredNode == leftArrow {
                        leftArrow.yScale = 7
                    }
                    rightArrow.yScale = -7
                    triggeredNode = rightArrow
                } else if loc.x <= 0 && index != 0 {
                    if triggeredNode == rightArrow {
                        rightArrow.yScale = 7
                    }
                    leftArrow.yScale = -7
                    triggeredNode = leftArrow
                }
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if triggeredNode == backBtn.sprite {
            backBtn.release()
        } else if triggeredNode == actBtn.sprite {
            actBtn.release()
            if !GameScene.ownedSkins.contains(ShopScene.skins[index]) {
                if actBtn.color == .yellow && hasEnoughMoney(for: ShopScene.skins[index]) && !GameScene.ownedSkins.contains(ShopScene.skins[index]) {
                    GameScene.ownedSkins.insert(ShopScene.skins[index])
                }
//                ShopScene.skins[index].owned = actBtn.color == .yellow && hasEnoughMoney(for: ShopScene.skins[index])
            } else {
                GameScene.currentSkin = ShopScene.skins[index]
            }
        } else if triggeredNode == rightArrow {
            index += 1
            rightArrow.yScale = 7
        } else if triggeredNode == leftArrow {
            index -= 1
            leftArrow.yScale = 7
        }

        loadSkin(skin: ShopScene.skins[index])
        loadButtonData(for: ShopScene.skins[index])
        triggeredNode = nil
    }
    
    override func update(_ currentTime: TimeInterval) {
        cam.shake(amplitude: 0.8, amount: 5, step: 0, duration: 2)
    }
    
    func loadSkin(skin: Skin) {
        self.skinSprite.texture = skin.texture
        self.skinTitle.text = skin.title
//        GameScene.currentSkin = skin
        
//        if skin.owned {
//            actBtn.setText(text: skin.set ? "CURRENT SKIN" : "SET SKIN")
//            actBtn.setColor(color: skin.set ? .blue : .green)
//            actBtn.label.children.first!.isHidden = true
//        } else {
//            actBtn.setPrice(amount: skin.price, currency: skin.currency)
//            actBtn.setColor(color: hasEnoughMoney(for: skin) ? .yellow : .gray)
//            actBtn.label.children.first!.isHidden = false
//        }
        
        for i in 0..<pages.count {
            pages[i].texture = SKTexture(imageNamed: i == index ? "current-page" : "inactive-page").px()
        }
        
        leftArrow.texture = SKTexture(imageNamed: index == 0 ? "disabled-arrow" : "arrow").px()
        rightArrow.texture = SKTexture(imageNamed: index == ShopScene.skins.count - 1 ? "disabled-arrow" : "arrow").px()
    }
    
    func loadButtonData(for skin: Skin) {
        if GameScene.currentSkin == skin {
            actBtn.set(text: "CURRENT SKIN", color: .blue, hideCoin: true)
        } else {
            if GameScene.ownedSkins.contains(skin) {
                actBtn.set(text: "SET SKIN", color: .green, hideCoin: true)
            } else {
                actBtn.setPrice(amount: skin.price, currency: skin.currency)
                actBtn.setColor(color: hasEnoughMoney(for: skin) ? .yellow : .gray)
                actBtn.label.children.first!.isHidden = false
            }
        }
    }
    
    func hasEnoughMoney(for skin: Skin) -> Bool {
        return (skin.currency == .wood && skin.price <= wooden) ||
            (skin.currency == .bronze && skin.price <= bronze) ||
            (skin.currency == .golden && skin.price <= golden)
    }
    
    func backToMain() {
        let waitFadeIn = SKAction.group([
            SKAction.wait(forDuration: 0.4),
            SKAction.run { self.fade.run(SKAction.fadeIn(withDuration: 0.4)) }
        ])
        
        let startScene = SKAction.run {
            GameScene.restarted = true
            let scene = GameScene(size: self.frame.size)
            scene.scaleMode = SKSceneScaleMode.aspectFill
            self.view!.presentScene(scene)
            self.removeAllChildren()
        }
        
        run(SKAction.sequence([waitFadeIn, startScene]))
    }
}
