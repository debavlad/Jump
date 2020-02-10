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
	var width, height, aspectRatio: CGFloat
	private(set) var menuBtn: Button!
	var emitters: Set<SKEmitterNode>
	var toRemove: Set<SKNode>
	var score: Int
	
	private(set) var gameOverLbl, curPtsLabel, menuScoreLbl, scorePts, scoreTxt, iconLabel,
		coinLabel, soundStats: SKLabelNode!
	private(set) var sliderPath, slider, blackSprite, hp, scoreParent, iconSprite, coinIcon: SKSpriteNode!
	
	
	init(_ scene: SKScene, _ world: SKNode) {
		self.scene = scene
		width = UIScreen.main.bounds.width
		height = UIScreen.main.bounds.height
		aspectRatio = height/width
		emitters = Set<SKEmitterNode>()
		toRemove = Set<SKNode>()
		score = 0
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
	
	func menu(_ visible: Bool) {
		if !visible {
			fade(0, 2, [blackSprite, menuBtn.node, gameOverLbl, scoreParent, iconSprite])
			show(hp, sliderPath)
		} else {
			scorePts.text = "\(score)"
			scorePts.position.x = scoreTxt.frame.maxX + scorePts.frame.width/2 + 15
			scoreParent.position.x = gameOverLbl.position.x - scorePts.frame.width/2
			iconSprite.position.x = -iconLabel.frame.width/2
			iconLabel.position.x = iconSprite.frame.maxX + iconLabel.frame.width + 30
			show(menuBtn.node, iconSprite, gameOverLbl, scoreParent)
			blackSprite.run(SKAction.fadeAlpha(to: 0.7, duration: 0.5))
			hide(hp, sliderPath)
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
	
	func updateScore(_ value: Int) {
		score = value
		curPtsLabel.text = String(value)
		curPtsLabel.position = CGPoint(x: -width + curPtsLabel.frame.width/2+60,
																		y: height - curPtsLabel.frame.height/2-100)
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
		
		let sky = SKSpriteNode(imageNamed: "sky")
		sky.size = scene.frame.size
		sky.zPosition = -10
		cam.addChild(sky)
		
		let bench = SKSpriteNode()
		bench.size = CGSize(width: 161, height: 34)
		bench.position = CGPoint(x: -173, y: -347)
		bench.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: bench.frame.width, height: bench.frame.height))
		bench.physicsBody?.categoryBitMask = Bit.ground
		bench.physicsBody?.isDynamic = false
		world.addChild(bench)
		toRemove.insert(bench)
			
		let hood = SKSpriteNode(imageNamed: "hood").px()
		hood.size = CGSize(width: 826, height: 945)
		hood.position = CGPoint(x: 30, y: -323)
		hood.zPosition = -1
		world.addChild(hood)
		toRemove.insert(hood)
			
		let player = SKSpriteNode(imageNamed: "sit0").px()
		player.name = "Character"
		player.size = CGSize(width: 132, height: 140)
		player.position = CGPoint(x: -160, y: GameScene.restarted ? -200 : -250)
		player.zPosition = 10
		world.addChild(player)
		
		// UI
		hp = SKSpriteNode(imageNamed: "hp").px()
		hp.size = CGSize(width: 100, height: 11)
		hp.position = CGPoint(x: hp.frame.midX, y: player.frame.height/2 + 10)
		hp.anchorPoint = CGPoint(x: 0.5, y: 0.5)
		hp.zPosition = -1
		hp.alpha = 0
		player.addChild(hp)
			
		sliderPath = SKSpriteNode(imageNamed: "slider-line").px()
		let scale = (width*2 - 130)/sliderPath.frame.width
		sliderPath.size = CGSize(width: sliderPath.frame.width*scale, height: sliderPath.frame.height*scale)
		sliderPath.position.y = -height + 90
		sliderPath.zPosition = 20
		sliderPath.alpha = 0
		
		slider = SKSpriteNode(imageNamed: "slider-0").px()
		slider.size = CGSize(width: 54, height: 54)
		slider.position.y = 4
		slider.zPosition = 21
			
		sliderPath.addChild(slider)
		cam.addChild(sliderPath)
		
		// Dead menu nodes
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
			
		scoreParent = SKSpriteNode()
		scoreParent.zPosition = 21
		scoreParent.alpha = 0
		scoreParent.position = CGPoint(x: gameOverLbl.position.x, y: gameOverLbl.frame.minY - 115)
		
		scoreTxt = SKLabelNode(fontNamed: Fonts.pixelf)
		scoreTxt.text = "SCORE:"
		scoreTxt.fontSize = 55
		scoreParent.addChild(scoreTxt)
			
		scorePts = SKLabelNode(fontNamed: Fonts.pixelf)
		scorePts.text = "0"
		scorePts.fontSize = 55
		scorePts.fontColor = UIColor(red: 253/255, green: 255/255, blue: 115/255, alpha: 1)
		scorePts.position.x = scoreTxt.frame.maxX + scorePts.frame.width/2 + 15
		scoreParent.addChild(scorePts)
		cam.addChild(scoreParent)
		
		curPtsLabel = SKLabelNode(fontNamed: Fonts.forwa)
		curPtsLabel.zPosition = 21
		curPtsLabel.alpha = 0
		curPtsLabel.text = "0"
		curPtsLabel.fontSize = 50
		curPtsLabel.position = CGPoint(x: -width + curPtsLabel.frame.width/2 + 100, y: height - curPtsLabel.frame.height/2 - 100)
		curPtsLabel.fontColor = UIColor(red: 84/255, green: 84/255, blue: 84/255, alpha: 1)
		cam.addChild(curPtsLabel)
			
		iconSprite = SKSpriteNode(imageNamed: "Coin0").px()
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
		
		menuBtn = Button("TO MENU", -height)
		menuBtn.node.alpha = 0
		cam.addChild(menuBtn.node)
		
		// Middle upper corner
		coinIcon = SKSpriteNode(imageNamed: "Coin0").px()
		coinIcon.size = CGSize(width: 72, height: 81)
		coinIcon.position.y = height - 130
		coinIcon.zPosition = 20
		cam.addChild(coinIcon)
		
		coinLabel = SKLabelNode(fontNamed: Fonts.pixelf)
		coinLabel.text = String((UserDefaults.standard.value(forKey: "coins") ?? 0) as! Int)
		coinLabel.fontSize = 62
		coinLabel.position.x = coinIcon.frame.width/2 + coinLabel.frame.width/2 + 25
		coinLabel.position.y = -coinLabel.frame.height/2 + 2
		coinLabel.fontColor = UIColor(red: 85/255, green: 85/255, blue: 85/255, alpha: 1)
		coinIcon.position.x -= coinLabel.frame.width/2 + 25
		coinIcon.addChild(coinLabel)
		
		soundStats = SKLabelNode(fontNamed: Fonts.pixelf)
		soundStats.text = Audio.shared.isEnabled ? "SOUND ON" : "SOUND OFF"
		soundStats.fontSize = 43
		soundStats.position = CGPoint(x: coinIcon.calculateAccumulatedFrame().midX, y: coinIcon.calculateAccumulatedFrame().minY - 70)
		soundStats.fontColor = UIColor(red: 70/255, green: 70/255, blue: 70/255, alpha: 1)
		soundStats.zPosition = 20
		cam.addChild(soundStats)
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
