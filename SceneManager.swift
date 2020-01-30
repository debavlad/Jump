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
	var emitters: Set<SKEmitterNode>
	var score = 0
	
	private(set) var gameOverLbl, gameScoreLbl, menuScoreLbl, pointsLbl, scoreLbl, iconLabel,
		wl: SKLabelNode!
	private(set) var house, door, controlLine, slider, blackSprite, hpLine, scoreLabel,
		iconSprite, w: SKSpriteNode!
	private(set) var smokeAnim, doorAnim: SKAction!
	
	
	init(_ scene: SKScene, _ world: SKNode) {
		self.scene = scene
		width = UIScreen.main.bounds.width
		height = UIScreen.main.bounds.height
		emitters = Set<SKEmitterNode>()
		loadAnims()
		setNodes(world)
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
	
	func fadeMenu(_ visible: Bool) {
		if !visible {
			fade(0, 2, [blackSprite, menuBtn.node, gameOverLbl, scoreLabel, iconSprite])
			show(hpLine, controlLine)
		} else {
			pointsLbl.text = "\(score)"
			pointsLbl.position.x = scoreLbl.frame.maxX + pointsLbl.frame.width/2 + 15
			scoreLabel.position.x = gameOverLbl.position.x - pointsLbl.frame.width/2
			iconSprite.position.x = -iconLabel.frame.width/2
			iconLabel.position.x = iconSprite.frame.maxX + iconLabel.frame.width + 30
			show(menuBtn.node, iconSprite, gameOverLbl, scoreLabel)
			fade(0.7, 1, [blackSprite])
			hide(hpLine, controlLine)
		}
	}
	
	func addEmitter(_ filename: String, _ parent: SKNode, _ pos: CGPoint) {
		let e = SKEmitterNode(fileNamed: filename)!
		e.position = pos
		e.name = ""
		e.zPosition = 3
		e.particleZPosition = 3
		parent.addChild(e)
		emitters.insert(e)
	}
	
	func updateScore(_ val: Int) {
		score = val
		gameScoreLbl.text = String(val)
		gameScoreLbl.position = CGPoint(x: -width + gameScoreLbl.frame.width/2+60,
																		y: height - gameScoreLbl.frame.height/2-100)
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
	
	
	private func setNodes(_ world: SKNode) {
		let cam = scene.childNode(withName: "Cam") as! SKCameraNode
		
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
		
			
		hpLine = SKSpriteNode(imageNamed: "hp-green").px()
		hpLine.size = CGSize(width: 100, height: 11)
		hpLine.position = CGPoint(x: hpLine.frame.midX, y: player.frame.height/2 + 10)
		hpLine.anchorPoint = CGPoint(x: 0.5, y: 0.5)
		hpLine.zPosition = -1
		hpLine.alpha = 0
		
		player.addChild(hpLine)
		world.addChild(player)
			
		controlLine = SKSpriteNode(imageNamed: "slider-line").px()
		controlLine.size = CGSize(width: 610, height: 28)
		controlLine.position.y = -height + 90
		controlLine.zPosition = 20
		controlLine.alpha = 0
		
		slider = SKSpriteNode(imageNamed: "slider-0").px()
		slider.size = CGSize(width: 54, height: 54)
		slider.position.y = 4
		slider.zPosition = 21
			
		controlLine.addChild(slider)
		cam.addChild(controlLine)
		
		blackSprite = SKSpriteNode()
		blackSprite.size = scene.frame.size
		blackSprite.alpha = 0
		blackSprite.color = UIColor.black
		blackSprite.zPosition = 20
		cam.addChild(blackSprite)
			
		gameOverLbl = SKLabelNode(fontNamed: Fonts.forwa)
		gameOverLbl.fontSize = 80
		gameOverLbl.text = "Game over!"
		gameOverLbl.zPosition = 21
		gameOverLbl.alpha = 0
		cam.addChild(gameOverLbl)
			
		scoreLabel = SKSpriteNode()
		scoreLabel.zPosition = 21
		scoreLabel.alpha = 0
		scoreLabel.position = CGPoint(x: gameOverLbl.position.x, y: gameOverLbl.frame.minY - 115)
		scoreLbl = SKLabelNode(fontNamed: Fonts.pixelf)
		scoreLbl.text = "SCORE:"
		scoreLbl.fontSize = 55
		scoreLabel.addChild(scoreLbl)
			
		pointsLbl = SKLabelNode(fontNamed: Fonts.pixelf)
		pointsLbl.text = "0"
		pointsLbl.fontSize = 55
		pointsLbl.fontColor = UIColor(red: 253/255, green: 255/255, blue: 115/255, alpha: 1)
		pointsLbl.position.x = scoreLbl.frame.maxX + pointsLbl.frame.width/2 + 15
		scoreLabel.addChild(pointsLbl)
		cam.addChild(scoreLabel)
		
		gameScoreLbl = SKLabelNode(fontNamed: Fonts.forwa)
		gameScoreLbl.zPosition = 21
		gameScoreLbl.alpha = 0
		gameScoreLbl.text = "0"
		gameScoreLbl.fontSize = 50
		gameScoreLbl.position = CGPoint(x: -width + gameScoreLbl.frame.width/2 + 100, y: height - gameScoreLbl.frame.height/2 - 100)
		gameScoreLbl.fontColor = UIColor(red: 84/255, green: 84/255, blue: 84/255, alpha: 1)
		cam.addChild(gameScoreLbl)
			
		// Dead menu icons
		iconSprite = SKSpriteNode(imageNamed: "Wood0").px()
		iconSprite.size = CGSize(width: 90, height: 99)
		iconSprite.position.y = gameOverLbl.frame.maxY + 80
		iconSprite.zPosition = 21
		iconSprite.alpha = 0
		iconLabel = SKLabelNode(fontNamed: Fonts.pixelf)
		iconLabel.text = "0"
		iconLabel.fontSize = 76
		iconLabel.position = CGPoint(x: 0, y: -iconLabel.frame.height/2 + 4)
		iconSprite.addChild(iconLabel)
		cam.addChild(iconSprite)
		
		// Left upper corner
		let defaults = UserDefaults.standard
		
		w = SKSpriteNode(imageNamed: "Wood0").px()
		w.size = CGSize(width: 72, height: 81)
		w.position.y = height - 130
		w.zPosition = 20
		cam.addChild(w)
		
		wl = SKLabelNode(fontNamed: Fonts.pixelf)
		wl.text = String((defaults.value(forKey: "wooden") ?? 0) as! Int)
		wl.fontSize = 62
		wl.position.x = w.frame.width/2 + wl.frame.width/2 + 25
		wl.position.y = -wl.frame.height/2 + 2
		wl.fontColor = UIColor(red: 84/255, green: 84/255, blue: 84/255, alpha: 1)
		w.position.x -= wl.frame.width/2 + 25
		w.addChild(wl)
			
		menuBtn = Button("TO MENU", .gray, CGPoint(x: 0, y: -500))
		menuBtn.node.alpha = 0
		cam.addChild(menuBtn.node)
		
//		advertBtn = Button("CONTINUE", .blue, CGPoint(x: 0, y: menuBtn.node.frame.maxY + 100))
//		advertBtn.node.alpha = 0
//		cam.addChild(advertBtn.node)
	}
	
	private func loadAnims() {
		var textures = [SKTexture]()
		for i in 0...3 { textures.append(SKTexture(imageNamed: "smoke\(i)").px()) }
		smokeAnim = SKAction.animate(with: textures, timePerFrame: 0.12)
		textures.removeAll(keepingCapacity: true)
		
		for i in 1...6 { textures.append(SKTexture(imageNamed: "door\(i)").px()) }
		doorAnim = SKAction.animate(with: textures, timePerFrame: 0.07)
		doorAnim.timingMode = .easeOut
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
