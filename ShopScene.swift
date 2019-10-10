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
    private var title: SKLabelNode!
    private var backBtn, actBtn: Button!
    private var currentNode: SKNode!
    private var cam: Camera!
    
    static var skins = [
        Skin(title: "Pauper", name: "pauper", texture: SKTexture(imageNamed: "pauper-sit0").px(), price: 0, currency: .wood),
        Skin(title: "Zombie", name: "zombie", texture: SKTexture(imageNamed: "zombie-sit0").px(), price: 100, currency: .wood),
        Skin(title: "Farmer", name: "farmer", texture: SKTexture(imageNamed: "farmer-sit0").px(), price: 50, currency: .bronze),
        Skin(title: "Businessman", name: "bman", texture: SKTexture(imageNamed: "bman-sit0").px(), price: 25, currency: .golden)
    ]
    private var pages: [SKSpriteNode]!
    private var index: Int!
    
    
    override func didMove(to view: SKView) {
        wooden = defaults.value(forKey: "wooden") as? Int ?? 0
        bronze = defaults.value(forKey: "bronze") as? Int ?? 0
        golden = defaults.value(forKey: "golden") as? Int ?? 0
        
        pages = []
        setScene()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let node = atPoint(touch.location(in: self))
        
        if node == actBtn.sprite || node == actBtn.label {
            actBtn.push()
            currentNode = actBtn.sprite
        }
        else if node == backBtn.sprite || node == backBtn.label {
            backBtn.push()
            currentNode = backBtn.sprite
            backToMain()
        } else {
            let loc = touch.location(in: self)
            if loc.y > skinSprite.frame.minY - 100 {
                if loc.x > 0 && index != ShopScene.skins.count - 1 {
                    if currentNode == leftArrow {
                        leftArrow.yScale = 7
                    }
                    rightArrow.yScale = -7
                    currentNode = rightArrow
                } else if loc.x <= 0 && index != 0 {
                    if currentNode == rightArrow {
                        rightArrow.yScale = 7
                    }
                    leftArrow.yScale = -7
                    currentNode = leftArrow
                }
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if currentNode == backBtn.sprite {
            backBtn.release()
        } else if currentNode == actBtn.sprite {
            actBtn.release()
            if !GameScene.ownedSkins.contains(index) {
                if actBtn.color == .yellow && hasEnoughMoney(for: ShopScene.skins[index]) && !GameScene.ownedSkins.contains(index) {
                    buySkin(index)
                }
            } else {
                GameScene.skinIndex = index
            }
            GameScene.saveData()
        } else if currentNode == rightArrow {
            index += 1
            rightArrow.yScale = 7
        } else if currentNode == leftArrow {
            index -= 1
            leftArrow.yScale = 7
        }

        loadSkin(ShopScene.skins[index])
        setButtonData(index)
        currentNode = nil
    }
    
    override func update(_ currentTime: TimeInterval) {
        cam.shake(0.8, 5, 0, 2)
    }
    
    
    private func buySkin(_ index: Int) {
        let skin = ShopScene.skins[index]
        
        switch (skin.currency) {
        case .wood:
            wooden -= skin.price
            defaults.set(wooden, forKey: "wooden")
        case .bronze:
            bronze -= skin.price
            defaults.set(bronze, forKey: "bronze")
        case .golden:
            golden -= skin.price
            defaults.set(golden, forKey: "golden")
        }
        
        GameScene.ownedSkins.append(index)
    }
    
    private func loadSkin(_ skin: Skin) {
        self.skinSprite.texture = skin.texture
        self.title.text = skin.title
        
        for i in 0..<pages.count {
            pages[i].texture = SKTexture(imageNamed: i == index ? "current-page" : "inactive-page").px()
        }
        
        leftArrow.texture = SKTexture(imageNamed: index == 0 ? "disabled-arrow" : "arrow").px()
        rightArrow.texture = SKTexture(imageNamed: index == ShopScene.skins.count - 1 ? "disabled-arrow" : "arrow").px()
    }
    
    private func setButtonData(_ skinIndex: Int) {
        if GameScene.skinIndex == skinIndex {
            actBtn.setText("CURRENT SKIN")
            actBtn.setColor(.blue)
            actBtn.icon!.isHidden = true
        } else {
            if GameScene.ownedSkins.contains(skinIndex) {
                actBtn.setText("SET SKIN")
                actBtn.setColor(.green)
                actBtn.icon!.isHidden = true
            } else {
                let skin = ShopScene.skins[skinIndex]
                actBtn.setPrice(skin.price, skin.currency)
                actBtn.setColor(hasEnoughMoney(for: skin) ? .yellow : .gray)
            }
        }
    }
    
    private func hasEnoughMoney(for skin: Skin) -> Bool {
        return (skin.currency == .wood && skin.price <= wooden) ||
            (skin.currency == .bronze && skin.price <= bronze) ||
            (skin.currency == .golden && skin.price <= golden)
    }
    
    private func backToMain() {
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
    
    private func setScene() {
        let skinName = ShopScene.skins[GameScene.skinIndex].name
        
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        let bg = SKSpriteNode(imageNamed: "shop-bg").px()
        bg.position.y = 110
        bg.size = frame.size
        addChild(bg)
        
        cam = Camera(self)
        cam.node.setScale(0.7)
        
        skinSprite = SKSpriteNode(imageNamed: "\(skinName)-jump0").px()
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
        
        title = SKLabelNode(fontNamed: "Coder's Crux")
        title.position.y = bg.position.y + 200
        title.zPosition = 2
        title.fontSize = 70
        addChild(title)
        
        fade = SKSpriteNode(color: .black, size: frame.size)
        fade.zPosition = 30
        addChild(fade)
        
        backBtn = Button("BACK TO MENU", .gray, CGPoint(x: 0, y: -height + 150))
        cam.node.addChild(backBtn.sprite)
        
        actBtn = Button(90, .wood, backBtn.sprite.position.y + 180)
        cam.node.addChild(actBtn.sprite)
        
        let pageCounter = SKNode()
//        pageCounter.position = CGPoint(x: -75, y: bg.position.y + 170)
        pageCounter.position.y = bg.position.y + 170
        pageCounter.zPosition = 2
        for i in 0..<ShopScene.skins.count {
            let page = SKSpriteNode(imageNamed: "inactive-page").px()
            page.position.x = 50 * CGFloat(i)
            page.setScale(4)
            pages.insert(page, at: i)
            pageCounter.addChild(page)
        }
        pageCounter.position.x = CGFloat(-25) * CGFloat(ShopScene.skins.count - 1)
        addChild(pageCounter)
        
        for i in 0..<ShopScene.skins.count {
            if ShopScene.skins[i].name == skinName {
                index = i
                loadSkin(ShopScene.skins[i])
                setButtonData(index)
                break
            }
        }
        
        let fadeOut = SKAction.fadeOut(withDuration: 0.3)
        fadeOut.timingMode = SKActionTimingMode.easeOut
        fade.run(fadeOut)
    }
}
