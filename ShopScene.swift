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

class Skin {
    let name, title, dsc: String
    let texture: SKTexture
    let price: Int
    let currency: Currency
    let trailColors: [UIColor]
    
    init(name: String, title: String, dsc: String, _ price: Int, _ currency: Currency, colors: [UIColor]) {
        self.name = name
        self.title = title
        self.dsc = dsc
        texture = SKTexture(imageNamed: "\(name)-sit0").px()
        self.price = price
        self.currency = currency
        trailColors = colors
    }
}

class ShopScene: SKScene {
    var wooden, bronze, golden: Int!
    private var black, lArr, rArr, character: SKSpriteNode!
    private var title, dsc: SKLabelNode!
    private var backBtn, actBtn: Button!
    private var triggeredNode: SKNode!
    private var cam: Camera!
    
    private var pages: [SKSpriteNode]!
    private var index: Int!
    let defaults = UserDefaults.standard
    
    
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
            triggeredNode = actBtn.sprite
            
            let sound: String
            switch actBtn.color {
            case .gray:
                sound = "error"
            case .yellow:
                sound = "purchase"
            default:
                sound = "button"
                break
            }
            GSAudio.sharedInstance.playAsync(soundFileName: sound)
        }
        else if node == backBtn.sprite || node == backBtn.label {
            backBtn.push()
            triggeredNode = backBtn.sprite
            GSAudio.sharedInstance.playAsync(soundFileName: "button")
            reloadScene()
        } else {
            let (x, y) = (touch.location(in: self).x, touch.location(in: self).y)
            if y > character.frame.minY - 100 {
                var arrow: SKSpriteNode? = nil
                if x > 0 && index != Skins.count - 1 {
                    arrow = rArr
                } else if x <= 0 && index != 0 {
                    arrow = lArr
                }
                triggeredNode?.yScale = 7
                arrow?.yScale = -7
                triggeredNode = arrow
                if (triggeredNode != nil) {
                    GSAudio.sharedInstance.playAsync(soundFileName: "button")
                }
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        switch triggeredNode {
        case backBtn.sprite:
            backBtn.release()
        case actBtn.sprite:
            actBtn.release()
            if !GameScene.ownedSkins.contains(index) {
                if actBtn.color == .yellow && enoughMoney(for: Skins[index]) {
                    buySkin(index)
                }
            } else {
                GameScene.skinIndex = index
            }
            GameScene.saveData()
        case rArr:
            index += 1
            rArr.yScale = 7
        case lArr:
            index -= 1
            lArr.yScale = 7
        default:
            break
        }

        loadSkin(Skins[index])
        setBtnData(index)
        triggeredNode = nil
    }
    
    override func update(_ currentTime: TimeInterval) {
        cam.shake(0.8, 5, 0, 2)
    }
    
    
    private func buySkin(_ index: Int) {
        let skin = Skins[index]
        
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
        self.character.texture = skin.texture
        self.title.text = skin.title
        
        for i in 0..<pages.count {
            pages[i].texture = SKTexture(imageNamed: i == index ? "current-page" : "inactive-page").px()
        }
        
        dsc.text = skin.dsc
        lArr.texture = SKTexture(imageNamed: index == 0 ? "disabled-arrow" : "arrow").px()
        rArr.texture = SKTexture(imageNamed: index == Skins.count - 1 ? "disabled-arrow" : "arrow").px()
    }
    
    private func setBtnData(_ skinIndex: Int) {
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
                let skin = Skins[skinIndex]
                actBtn.setPrice(skin.price, skin.currency)
                actBtn.setColor(enoughMoney(for: skin) ? .yellow : .gray)
            }
        }
    }
    
    private func enoughMoney(for skin: Skin) -> Bool {
        return (skin.currency == .wood && skin.price <= wooden) ||
            (skin.currency == .bronze && skin.price <= bronze) ||
            (skin.currency == .golden && skin.price <= golden)
    }
    
    private func reloadScene() {
        let waitFadeIn = SKAction.group([
            SKAction.wait(forDuration: 0.3),
            SKAction.run { self.black.run(SKAction.fadeIn(withDuration: 0.3)) }
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
        let skinName = Skins[GameScene.skinIndex].name
        
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        let bg = SKSpriteNode(imageNamed: "shop-bg").px()
        bg.position.y = 110
        bg.size = frame.size
        addChild(bg)
        
        cam = Camera(self)
        cam.node.setScale(0.7)
        
        character = SKSpriteNode(imageNamed: "\(skinName)-jump0").px()
        character.position = CGPoint(x: 0, y: bg.position.y - 90)
        character.zPosition = 2
        character.xScale = -3
        character.yScale = 3
        addChild(character)
        
        lArr = SKSpriteNode(imageNamed: "disabled-arrow").px()
        lArr.position = CGPoint(x: -250, y: character.position.y)
        lArr.zPosition = 2
        lArr.xScale = -7
        lArr.yScale = 7
        cam.node.addChild(lArr)
        
        rArr = SKSpriteNode(imageNamed: "arrow").px()
        rArr.position = CGPoint(x: 250, y: character.position.y)
        rArr.zPosition = 2
        rArr.setScale(7)
        cam.node.addChild(rArr)
        
        title = SKLabelNode(fontNamed: "pixelFJ8pt1")
        title.position.y = bg.position.y + 205
        title.zPosition = 2
        title.fontSize = 40
        addChild(title)
        
        black = SKSpriteNode(color: .black, size: frame.size)
        black.zPosition = 30
        addChild(black)
        
        backBtn = Button("BACK TO MENU", .gray, CGPoint(x: 0, y: -UIScreen.main.bounds.height + 150))
        cam.node.addChild(backBtn.sprite)
        
        actBtn = Button(90, .wood, backBtn.sprite.position.y + 180)
        cam.node.addChild(actBtn.sprite)
        
        let pageCounter = SKNode()
//        pageCounter.position = CGPoint(x: -75, y: bg.position.y + 170)
        pageCounter.position.y = title.position.y - 30
        pageCounter.zPosition = 2
        for i in 0..<Skins.count {
            let page = SKSpriteNode(imageNamed: "inactive-page").px()
            page.position.x = 50 * CGFloat(i)
            page.setScale(4)
            pages.insert(page, at: i)
            pageCounter.addChild(page)
        }
        pageCounter.position.x = CGFloat(-25) * CGFloat(Skins.count - 1)
        addChild(pageCounter)
        
        dsc = SKLabelNode(fontNamed: "pixelFJ8pt1")
        dsc.position.y = pageCounter.position.y - 50
        dsc.zPosition = 2
        dsc.text = "Default"
        dsc.fontSize = 26
        addChild(dsc)
        
        for i in 0..<Skins.count {
            if Skins[i].name == skinName {
                index = i
                loadSkin(Skins[i])
                setBtnData(index)
                break
            }
        }
        
        let fadeOut = SKAction.fadeOut(withDuration: 0.25)
        fadeOut.timingMode = SKActionTimingMode.easeOut
        black.run(fadeOut)
    }
}
