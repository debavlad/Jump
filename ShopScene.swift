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

class ShopScene: SKScene {
	var wooden, bronze, golden: Int!
	private var black, leftArr, rightArr, mannequin: SKSpriteNode!
	private var title, dsc: SKLabelNode!
	private var backBtn, actBtn: Button!
	private var touchedNode: SKNode!
	private var cam: Camera!
	
	private var id: Int!
	private var pages: [SKSpriteNode]!
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
		if node == actBtn.node || node == actBtn.label {
			actBtn.push()
			touchedNode = actBtn.node
			let sound: String
			switch actBtn.color {
				case .gray: sound = "error"
				case .yellow: sound = "purchase"
				default: sound = "button"
			}
		}
		else if node == backBtn.node || node == backBtn.label {
			backBtn.push()
			touchedNode = backBtn.node
			reload()
		}
		else {
			let (x, y) = (touch.location(in: self).x, touch.location(in: self).y)
			if y <= mannequin.frame.minY - 100 { return }
			
			var arrow: SKSpriteNode? = nil
			if x > 0 && id != Skins.count-1 { arrow = rightArr }
			else if x <= 0 && id != 0 { arrow = leftArr }
			touchedNode?.yScale = 7
			arrow?.yScale = -7
			touchedNode = arrow
		}
	}
	
	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		switch touchedNode {
			case backBtn.node:
				backBtn.release()
			case actBtn.node:
				actBtn.release()
				if GameScene.ownedSkins.contains(id) { GameScene.skinIndex = id }
				else if actBtn.color == .yellow && enoughMoney(for: Skins[id]) { buySkin(id) }
				GameScene.saveDef()
			case leftArr:
				id -= 1
				leftArr.yScale = 7
			case rightArr:
				id += 1
				rightArr.yScale = 7
			default: break
		}
		loadSkin(Skins[id])
		setSkinBtn(id)
		touchedNode = nil
	}
	
	override func update(_ currentTime: TimeInterval) {
		cam.shake(0.8, 5, 0, 2)
	}
    
	
	private func buySkin(_ id: Int) {
		let skin = Skins[id]
		switch (skin.currency) {
			case .Wood:
				wooden -= skin.price
				defaults.set(wooden, forKey: "wooden")
			case .Bronze:
				bronze -= skin.price
				defaults.set(bronze, forKey: "bronze")
			case .Golden:
				golden -= skin.price
				defaults.set(golden, forKey: "golden")
		}
		GameScene.ownedSkins.append(id)
	}
	
	private func loadSkin(_ skin: Skin) {
		mannequin.texture = skin.texture
		title.text = skin.title
		for i in 0..<pages.count {
			pages[i].texture = SKTexture(imageNamed: i == id ? "current-page" : "inactive-page").px()
		}
		dsc.text = skin.dsc
		leftArr.texture = SKTexture(imageNamed: id == 0 ? "disabled-arrow" : "arrow").px()
		rightArr.texture = SKTexture(imageNamed: id == Skins.count - 1 ? "disabled-arrow" : "arrow").px()
	}
	
	private func setSkinBtn(_ skinId: Int) {
		if GameScene.skinIndex == skinId {
			actBtn.textContent("current skin")
			actBtn.setColor(.blue)
			actBtn.coin?.isHidden = true
		} else if GameScene.ownedSkins.contains(skinId) {
			actBtn.textContent("set skin")
			actBtn.setColor(.green)
			actBtn.coin?.isHidden = true
		} else {
			let skin = Skins[skinId]
			actBtn.priceContent(skin.price, skin.currency)
			actBtn.setColor(enoughMoney(for: skin) ? .yellow : .gray)
		}
	}
    
	private func enoughMoney(for skin: Skin) -> Bool {
		return (skin.currency == .Wood && skin.price <= wooden) ||
				(skin.currency == .Bronze && skin.price <= bronze) ||
				(skin.currency == .Golden && skin.price <= golden)
	}
	
	private func reload() {
		let delayFade = SKAction.group([
			SKAction.wait(forDuration: 0.3),
			SKAction.run { self.black.run(SKAction.fadeIn(withDuration: 0.3)) }
		])
		let start = SKAction.run {
			GameScene.restarted = true
			let scene = GameScene(size: self.frame.size)
			scene.scaleMode = .aspectFill
			self.view!.presentScene(scene)
			self.removeAllChildren()
		}
		run(SKAction.sequence([delayFade, start]))
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
		
		mannequin = SKSpriteNode(imageNamed: "\(skinName)-jump0").px()
		mannequin.position = CGPoint(x: 0, y: bg.position.y - 90)
		mannequin.zPosition = 2
		mannequin.xScale = -3
		mannequin.yScale = 3
		addChild(mannequin)
		
		leftArr = SKSpriteNode(imageNamed: "disabled-arrow").px()
		leftArr.position = CGPoint(x: -250, y: mannequin.position.y)
		leftArr.zPosition = 2
		leftArr.xScale = -7
		leftArr.yScale = 7
		cam.node.addChild(leftArr)
		
		rightArr = SKSpriteNode(imageNamed: "arrow").px()
		rightArr.position = CGPoint(x: 250, y: mannequin.position.y)
		rightArr.zPosition = 2
		rightArr.setScale(7)
		cam.node.addChild(rightArr)
		
		title = SKLabelNode(fontNamed: Fonts.pixelf)
		title.position.y = bg.position.y + 205
		title.zPosition = 2
		title.fontSize = 40
		addChild(title)
		
		black = SKSpriteNode(color: .black, size: frame.size)
		black.zPosition = 30
		addChild(black)
		
		backBtn = Button("BACK TO MENU", .gray, CGPoint(x: 0, y: -UIScreen.main.bounds.height + 150))
		cam.node.addChild(backBtn.node)
		
		actBtn = Button(90, .Wood, backBtn.node.position.y + 180)
		cam.node.addChild(actBtn.node)
		
		let pageCounter = SKNode()
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
		
		dsc = SKLabelNode(fontNamed: Fonts.pixelf)
		dsc.position.y = pageCounter.position.y - 50
		dsc.zPosition = 2
		dsc.text = "Default"
		dsc.fontSize = 26
		addChild(dsc)
		
		for i in 0..<Skins.count {
				if Skins[i].name == skinName {
						id = i
						loadSkin(Skins[i])
						setSkinBtn(id)
						break
				}
		}
		
		let fadeOut = SKAction.fadeOut(withDuration: 0.25)
		fadeOut.timingMode = SKActionTimingMode.easeOut
		black.run(fadeOut)
	}
}
