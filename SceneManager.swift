//
//  SceneManager.swift
//  Jump
//
//  Created by Vladislav Deba on 8/5/19.
//  Copyright © 2019 Vladislav Deba. All rights reserved.
//

import Foundation
import SpriteKit

class SceneManager {
	private let scene: SKScene
	private var width, height: CGFloat
	private(set) var menuBtn, advertBtn: Button!
	
	
	var soundButton: ButtonStruct
	// to-do: remove additional labels
	private(set) var largeGameOverLbl, gameScoreLbl, menuScoreLbl, ptsScoreLbl, scoreLbl, woodLbl,
		bronzeLbl, goldLbl, wl, bl, gl, btmStageLbl, topStageLbl, continueLbl, sampleLbl, pausedLbl: SKLabelNode!
	private(set) var house, door, line, slider, blackSprite, redSprite, hpBorder, hpStripe,
		mScore, wIcon, bIcon, gIcon, w, b, g: SKSpriteNode!
	private(set) var pauseTexture, playTexture: SKTexture!
	private(set) var smokeAnim, doorAnim: SKAction!
	var score = 0
	
	var emitters: Set<SKEmitterNode>
    
	
	init(_ scene: SKScene, _ world: SKNode) {
		self.scene = scene
		width = UIScreen.main.bounds.width
		height = UIScreen.main.bounds.height
		
		soundButton = ButtonStruct(node: SKSpriteNode(imageNamed: SOUND_ENABLED ? "blue-s1" : "gray-s1").px(), textures: [SKTexture(imageNamed: "blue-s1"), SKTexture(imageNamed: "blue-s2"),
		SKTexture(imageNamed: "gray-s1"), SKTexture(imageNamed: "gray-s2")])
		soundButton.node.setScale(9)
		soundButton.node.position = CGPoint(x: width-115, y: height-115)
		soundButton.node.zPosition = 21
		
		emitters = Set<SKEmitterNode>()
		
		createAnims()
		createNodes(world)
	}
	
	func pick(_ item: Item) {
		let name = "\(item.node.name!.dropLast(4))"
		guard let em = SKEmitterNode(fileNamed: name) else { return }
		if let parent = item.node.parent, let world = parent.parent {
			em.position = CGPoint(x: parent.position.x + item.node.position.x,
														y: parent.position.y + item.node.position.y)
			em.zPosition = 3
			world.addChild(em)
			emitters.insert(em)
		}
		item.node.removeFromParent()
	}
	
	func menuVisiblity(_ visible: Bool) {
		if !visible {
			fade(0, 2, [menuBtn.node, wIcon, bIcon, gIcon, largeGameOverLbl, mScore, blackSprite, redSprite])
			show(line, hpBorder)
		} else {
			ptsScoreLbl.text = "\(score)"
			ptsScoreLbl.position.x = scoreLbl.frame.maxX + ptsScoreLbl.frame.width/2 + 15
			mScore.position = CGPoint(x: largeGameOverLbl.position.x - ptsScoreLbl.frame.width/2,
																y: largeGameOverLbl.position.y - 100)
			hide(line, hpStripe)
			for (icon, label) in [(wIcon, woodLbl), (bIcon, bronzeLbl), (gIcon, goldLbl)] {
					icon!.position.x = -label!.frame.width/2
					label!.position.x = icon!.frame.maxX + label!.frame.width + 30
			}
			show(menuBtn.node, advertBtn.node, wIcon, bIcon, gIcon, largeGameOverLbl, mScore)
			fade(0.7, 1, [blackSprite])
			fade(0.4, 0.6, [redSprite])
		}
	}
  
	func updateScore(_ val: Int) {
		score = val
		gameScoreLbl.text = String(val)
		gameScoreLbl.position = CGPoint(x: -width + gameScoreLbl.frame.width/2+60,
																		y: height - gameScoreLbl.frame.height/2-100)
	}
	
	func iterateCoin(_ c: Currency) {
		let lbl: SKLabelNode
		switch c {
			case .Wood: lbl = woodLbl
			case .Bronze: lbl = bronzeLbl
			case .Golden: lbl = goldLbl
		}
		lbl.text = String(Int(lbl.text!)! + 1)
	}
	
	func createEmitter(_ filename: String, _ parent: SKNode, _ pos: CGPoint) {
		let e = SKEmitterNode(fileNamed: filename)!
		e.position = pos
		e.name = ""
		e.zPosition = 3
		e.particleZPosition = 3
		parent.addChild(e)
		emitters.insert(e)
	}
	
	func show(_ nodes: SKNode...) {
		fade(1.0, 2, nodes)
	}

	func hide(_ nodes: SKNode...) {
		fade(0, 0.6, nodes)
	}
	
	
	private func fade(_ alpha: CGFloat, _ duration: TimeInterval, _ nodes: [SKNode]) {
		let a = SKAction.fadeAlpha(to: alpha, duration: duration)
		a.timingMode = SKActionTimingMode.easeOut
		a.speed = 4
		for node in nodes {
			node.run(a)
		}
	}
	
	private func createNodes(_ world: SKNode) {
		let cam = scene.childNode(withName: "Cam") as! SKCameraNode
//		cam.addChild(soundButton.node)
		
		// Scene world objects
		
		let sky = SKSpriteNode(imageNamed: "sky").px()
		sky.size = scene.frame.size
		sky.zPosition = -10
		cam.addChild(sky)
		
		house = SKSpriteNode(imageNamed: "house").px()
		house.size = CGSize(width: 543, height: 632)
		house.position = CGPoint(x: 200, y: -47)
		house.zPosition = 0
		world.addChild(house)
			
		door = SKSpriteNode(imageNamed: "door0").px()
		door.size = CGSize(width: 112, height: 134)
		door.position = CGPoint(x: -119, y: -220)
		door.zPosition = 1
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
		bench.physicsBody?.categoryBitMask = Bit.ground
		bench.physicsBody?.isDynamic = false
		world.addChild(bench)
			
		let ground = SKSpriteNode(imageNamed: "ground").px()
		ground.size = CGSize(width: 826, height: 518)
		ground.position = CGPoint(x: 30, y: -530)
		ground.zPosition = -1
		world.addChild(ground)
			
		let player = SKSpriteNode(imageNamed: "\(Skins[GameScene.skinIndex].name)-sit0").px()
		player.name = "Character"
		player.size = CGSize(width: 132, height: 140)
		player.position = CGPoint(x: -160, y: GameScene.restarted ? -200 : -250)
		player.zPosition = 10
			
		// UI
			
//		hpBorder = SKSpriteNode(imageNamed: "hp-border").px()
//		hpBorder.size = CGSize(width: 84, height: 11)
//		hpBorder.position = CGPoint(x: 0, y: player.frame.height/2 + 10)
//		hpBorder.alpha = 0
		
		hpStripe = SKSpriteNode(imageNamed: "hp-green").px()
		hpStripe.size = CGSize(width: 100, height: 11)
		hpStripe.position = CGPoint(x: hpStripe.frame.midX, y: player.frame.height/2 + 10)
		hpStripe.anchorPoint = CGPoint(x: 0.5, y: 0.5)
		hpStripe.zPosition = -1
		hpStripe.alpha = 0
		
		player.addChild(hpStripe)
//		hpBorder.addChild(hpStripe)
//		player.addChild(hpBorder)
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
			
		redSprite = SKSpriteNode()
		redSprite.size = scene.frame.size
		redSprite.blendMode = SKBlendMode.add
		redSprite.color = UIColor.init(red: 120/255, green: 0, blue: 0, alpha: 1)
		redSprite.alpha = 0
		redSprite.zPosition = 20
		cam.addChild(redSprite)
		
		blackSprite = SKSpriteNode()
		blackSprite.size = scene.frame.size
		blackSprite.alpha = 0
		blackSprite.color = UIColor.black
		blackSprite.zPosition = 20
		cam.addChild(blackSprite)
			
		largeGameOverLbl = SKLabelNode(fontNamed: Fonts.forwa)
		largeGameOverLbl.fontSize = 80
		largeGameOverLbl.text = "Game over!"
		largeGameOverLbl.position.y = 460
		largeGameOverLbl.zPosition = 21
		largeGameOverLbl.alpha = 0
		cam.addChild(largeGameOverLbl)
			
		mScore = SKSpriteNode()
		mScore.zPosition = 21
		mScore.alpha = 0
		mScore.position = CGPoint(x: largeGameOverLbl.position.x, y: largeGameOverLbl.position.y - 100)
		scoreLbl = SKLabelNode(fontNamed: Fonts.pixelf)
		scoreLbl.text = "SCORE:"
		scoreLbl.fontSize = 55
		mScore.addChild(scoreLbl)
			
		ptsScoreLbl = SKLabelNode(fontNamed: Fonts.pixelf)
		ptsScoreLbl.text = "0"
		ptsScoreLbl.fontSize = 55
		ptsScoreLbl.fontColor = UIColor(red: 253/255, green: 255/255, blue: 115/255, alpha: 1)
		ptsScoreLbl.position.x = scoreLbl.frame.maxX + ptsScoreLbl.frame.width/2 + 15
		mScore.addChild(ptsScoreLbl)
		cam.addChild(mScore)
		
		continueLbl = SKLabelNode(fontNamed: Fonts.pixelf)
		continueLbl.text = "TIME TO CONTINUE!"
		continueLbl.fontSize = 45
		continueLbl.position.y = -490
		continueLbl.zPosition = 21
		continueLbl.isHidden = true
		cam.addChild(continueLbl)
		
		gameScoreLbl = SKLabelNode(fontNamed: Fonts.forwa)
		gameScoreLbl.zPosition = 21
		gameScoreLbl.alpha = 0
		gameScoreLbl.text = "0"
		gameScoreLbl.fontSize = 50
		gameScoreLbl.position = CGPoint(x: -width + gameScoreLbl.frame.width/2 + 100, y: height - gameScoreLbl.frame.height/2 - 100)
		gameScoreLbl.fontColor = UIColor(red: 84/255, green: 84/255, blue: 84/255, alpha: 1)
		cam.addChild(gameScoreLbl)
			
		// Dead menu icons
		
		let icons = SKNode()
		wIcon = SKSpriteNode(imageNamed: "Wood0").px()
		wIcon.size = CGSize(width: 90, height: 99)
		wIcon.position.y = 120 // +50
		wIcon.zPosition = 21
		wIcon.alpha = 0
		icons.addChild(wIcon)

		woodLbl = SKLabelNode(fontNamed: Fonts.pixelf)
		woodLbl.text = "0"
		woodLbl.fontSize = 76
		woodLbl.position = CGPoint(x: 0, y: -woodLbl.frame.height/2 + 4)
		wIcon.addChild(woodLbl)
		
		bIcon = SKSpriteNode(imageNamed: "Bronze0").px()
		bIcon.size = CGSize(width: 90, height: 99)
		bIcon.position.y = -30
		bIcon.zPosition = 21
		bIcon.alpha = 0
		icons.addChild(bIcon)
		
		bronzeLbl = SKLabelNode(fontNamed: Fonts.pixelf)
		bronzeLbl.text = "0"
		bronzeLbl.fontSize = 76
		bronzeLbl.position = CGPoint(x: 0, y: -bronzeLbl.frame.height/2 + 4)
		bIcon.addChild(bronzeLbl)
		
		gIcon = SKSpriteNode(imageNamed: "Golden0").px()
		gIcon.size = CGSize(width: 90, height: 99)
		gIcon.position.y = -180
		gIcon.zPosition = 21
		gIcon.alpha = 0
		icons.addChild(gIcon)
		
		goldLbl = SKLabelNode(fontNamed: Fonts.pixelf)
		goldLbl.text = "0"
		goldLbl.fontSize = 76
		goldLbl.position = CGPoint(x: 0, y: -goldLbl.frame.height/2 + 4)
		gIcon.addChild(goldLbl)
		
		icons.position.y = 30
		cam.addChild(icons)
			
		
		// Left upper corner
		let defaults = UserDefaults.standard
		
		w = SKSpriteNode(imageNamed: "Wood0").px()
		w.size = CGSize(width: 72, height: 81)
		w.position.y = height - 100
		w.position.x = -width + 100
		cam.addChild(w)
			
		wl = SKLabelNode(fontNamed: Fonts.pixelf)
		wl.text = String((defaults.value(forKey: "wooden") ?? 0) as! Int)
		wl.fontSize = 62
		wl.position.x = w.frame.width/2 + wl.frame.width/2 + 25
		wl.position.y = -wl.frame.height/2 + 2
		wl.fontColor = UIColor(red: 84/255, green: 84/255, blue: 84/255, alpha: 1)
		w.addChild(wl)
		
		b = SKSpriteNode(imageNamed: "Bronze0").px()
		b.size = CGSize(width: 72, height: 81)
		b.position.y = w.frame.minY - 70
		b.position.x = -width + 100
//		cam.addChild(b)
		
		bl = SKLabelNode(fontNamed: Fonts.pixelf)
		bl.text = String((defaults.value(forKey: "bronze") ?? 0) as! Int)
		bl.fontSize = 62
		bl.position.x = b.frame.width/2 + bl.frame.width/2 + 25
		bl.position.y = -bl.frame.height/2 + 2
		bl.fontColor = UIColor(red: 84/255, green: 84/255, blue: 84/255, alpha: 1)
//		b.addChild(bl)
		
		g = SKSpriteNode(imageNamed: "Golden0").px()
		g.size = CGSize(width: 72, height: 81)
		g.position.y = b.frame.minY - 70
		g.position.x = -width + 100
//		cam.addChild(g)
		
		gl = SKLabelNode(fontNamed: Fonts.pixelf)
		gl.text = String((defaults.value(forKey: "golden") ?? 0) as! Int)
		gl.fontSize = 62
		gl.position.x = g.frame.width/2 + gl.frame.width/2 + 25
		gl.position.y = -gl.frame.height/2 + 2
		gl.fontColor = UIColor(red: 84/255, green: 84/255, blue: 84/255, alpha: 1)
//		g.addChild(gl)
			
		menuBtn = Button("BACK TO MENU", .gray, CGPoint(x: 0, y: -500))
		menuBtn.node.alpha = 0
		cam.addChild(menuBtn.node)
		
		advertBtn = Button("CONTINUE", .blue, CGPoint(x: 0, y: menuBtn.node.frame.maxY + 100))
		advertBtn.node.alpha = 0
		cam.addChild(advertBtn.node)
		
		// Coin pickup sample label
		
		sampleLbl = SKLabelNode(text: "+1")
		sampleLbl.name = ""
		sampleLbl.fontName = Fonts.droid
		sampleLbl.fontColor = UIColor.white
		sampleLbl.fontSize = 64
		sampleLbl.zPosition = 5
		
		sampleLbl.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 50, height: 20))
		sampleLbl.physicsBody?.collisionBitMask = 0
		sampleLbl.physicsBody?.categoryBitMask = 0
		sampleLbl.physicsBody?.contactTestBitMask = 0
	}
	
	private func createAnims() {
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
