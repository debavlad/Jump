//
//  GameScene.swift
//  Jump
//
//  Created by Vladislav Deba on 7/30/19.
//  Copyright © 2019 Vladislav Deba. All rights reserved.
//

import SpriteKit
import GameplayKit
import AVFoundation

class GameScene: SKScene, SKPhysicsContactDelegate {
	// scene
	private var cam: Camera!
	private var manager: SceneManager!
	private var bg, fg: CloudFactory!
	private var platforms: PlatformFactory!
	private var world: SKNode!
	private var player: Player!
	private var trail: Trail!
	// ui
	private var sliderTip, doorTip: Tip!
	private var fade: SKSpriteNode!
	private var sliderTouch: UITouch?
	private var triggeredBtn: Button!
	// raw
	static var restarted = false
	static var skinIndex: Int!
	static var ownedSkins: [Int]!
	var bonusPoints = 0, doorOpens = false
	private var started = false, stopped = false, ended = false
	private var movement, offset, minY: CGFloat!
	
	
	override func didMove(to view: SKView) {
		loadDefaults()
		fade = SKSpriteNode(color: .black, size: frame.size)
		fade.alpha = GameScene.restarted ? 1 : 0
		fade.zPosition = 25
		
		physicsWorld.contactDelegate = self
		physicsWorld.gravity = CGVector(dx: 0, dy: -24)
		
		cam = Camera(self)
		cam.node.addChild(fade)
		cam.node.position.y = -60
		
		world = SKNode()
		manager = SceneManager(self, world)
		manager.show(manager.line)
		
		player = Player(world.childNode(withName: "Character")!)
		player.turn(left: true)
		
		sliderTip = Tip("HOLD AND MOVE", CGPoint(x: 35, y: 70))
		manager.slider.addChild(sliderTip.node)
		
		doorTip = Tip("SKIN SHOP", CGPoint(x: -50, y: 100))
		doorTip.flip(0.75)
		manager.door.addChild(doorTip.node)
		
		addChild(world)
		trail = Trail(player.node, Skins[GameScene.skinIndex].trailColors)
		trail.create(in: world)
		
		bg = CloudFactory(250, -frame.height)
		fg = CloudFactory(1200, -frame.height/1.25)
		platforms = PlatformFactory(world, frame.height/2, 125...200)
		bounds = Bounds()
		minY = player.node.position.y
		
		manager.slider.position.x = player.node.position.x
		movement = player.node.position.x
		cam.node.setScale(0.75)
		
		if GameScene.restarted {
			let a = SKAction.fadeOut(withDuration: 0.25)
			a.timingMode = .easeOut
			fade.run(a)
		}
		
		NotificationCenter.default.addObserver(self, selector: #selector(GameScene.watchedAd), name: NSNotification.Name(rawValue: "watchedAd"), object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(GameScene.dismissedAd), name: NSNotification.Name(rawValue: "dismissedAd"), object: nil)
		Audio.playSound("wind")
	}
	
	func didBegin(_ contact: SKPhysicsContact) {
		if !player.isAlive { return }
		let col: UInt32 = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
		if let node = extractNode("item", contact), col == Collision.playerFood || col == Collision.playerCoin {
			platforms.findItem(node).wasTouched = true
		}
		
		// Bird
		if col == Collision.playerBird {
			guard let bird = extractNode("bird", contact) else { return }
			manager.createEmitter(world, "BirdParticles", bird.position)
			cam.shake(40, 1, 0, 0.12)
			Audio.playSound("bird")
			bird.removeFromParent()
			
			if !player.isFalling() {
				player.push(power: 70)
				player.editHp(-15)
				Audio.playSound("hurt")
			} else { player.push(power: 80) }
		}
		
		// Platform
		if !(player.isFalling() && col == Collision.playerPlatform) { return }
		player.runAnim(player.landAnim)
		trail.create(in: world, 30.0)
		manager.createEmitter(world, "DustParticles", contact.contactPoint)
		guard let node = extractNode("platform", contact) else { return }
		let platform = platforms.findPlatform(node)
		Audio.playSounds("\(platform.type)-footstep", "wind")
		
		if platform.hasItems() {
			cam.shake(35, 1, 0, 0.12)
			for item in platform.items {
				switch (item) {
					case is Coin:
						pickItem(item, platform)
						manager.collectCoin((item as! Coin).currency)
					case is Food:
						var energy = CGFloat((item as! Food).energy)
						energy *= Skins[GameScene.skinIndex].name == "farmer" ? 1.25 : 1
						player.editHp(Int(energy))
						pickItem(item, platform)
					default: return
				}
			}
		} else { cam.shake(25, 1, 0, 0.12) }
		
		player.editHp(-platform.damage)
		if player.isAlive {
			let power: CGFloat = Skins[GameScene.skinIndex].name == "ninja" ?
				CGFloat(platform.power) * 1.125 : CGFloat(platform.power)
			player.push(power: Int(power))
		} else { finish(0.5) }
		
		if platform.type == .sand { platform.fall(contact.contactPoint.x) }
	}
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		let touch = touches.first!
		let node = atPoint(touch.location(in: self))
		
		if node == manager.soundButton.node {
			SOUND_ENABLED = !SOUND_ENABLED
			manager.soundButton.pressed = true
			manager.soundButton.node.texture = manager.soundButton.textures[SOUND_ENABLED ? 3 : 1].px()
			GameScene.saveDefaults()
		}
		
		if !started {
			if node == manager.slider && !doorOpens {
				// when the game starts
				sliderTouch = touch
				offset = manager.slider.position.x - sliderTouch!.location(in: cam.node).x
				manager.slider.texture = SKTexture(imageNamed: "slider-1").px()
				bonusPoints = Skins[GameScene.skinIndex].name == "bman" ? 100 : 0
				player.node.removeAllActions()
				bg.speed *= 2.5; fg.speed *= 2.5
				manager.show(manager.line, manager.hpBorder, manager.gameScoreLbl)
				manager.hide(sliderTip.node, manager.soundButton.node, manager.w, manager.b, manager.g)
				
				let scale = SKAction.scale(to: 0.95, duration: 1.25)
				scale.timingMode = .easeInEaseOut
				player.push(power: 170)
				cam.shake(50, 6, 6, 0.055)
				cam.node.run(scale)
				doorTip.node.alpha = 0
				Audio.playSounds("button", "wood-footstep", "wind")
				
			} else if node == manager.door {
				// go to the shop
				doorOpens = true
				manager.door.run(manager.doorAnim)
				manager.hide(manager.line, manager.w, manager.b, manager.g)
				let scale = SKAction.scale(to: 0.025, duration: 0.6)
				scale.timingMode = SKActionTimingMode.easeInEaseOut
				let targetPos = CGPoint(x: manager.house.position.x + manager.door.frame.maxX,
																y: manager.house.position.y + manager.door.frame.minY)
				let move = SKAction.move(to: targetPos, duration: 0.6)
				move.timingMode = SKActionTimingMode.easeIn
				let fade = SKAction.run {
					let a = SKAction.fadeIn(withDuration: 0.4)
					a.timingMode = .easeIn
					self.fade.run(a)
				}
				let load = SKAction.run {
					let s = ShopScene(size: self.frame.size)
					self.view!.presentScene(s)
					self.removeAllChildren()
				}
				run(SKAction.sequence([SKAction.group([SKAction.wait(forDuration: 0.4), fade]), load]))
				cam.node.run(SKAction.group([scale, move]))
				Audio.playSound("door-open")
			}
		}
		else if started && !ended {
			if node == manager.slider {
				// slider triggered during the game
				sliderTouch = touch
				offset = manager.slider.position.x - sliderTouch!.location(in: cam.node).x
				manager.slider.texture = SKTexture(imageNamed: "slider-1").px()
				Audio.playSound("button")
			}
		}
		else if ended {
			// when the game is finished
			if node == manager.slider {
				sliderTouch = touch
				offset = manager.slider.position.x - sliderTouch!.location(in: cam.node).x
				manager.slider.texture = SKTexture(imageNamed: "slider-1").px()
				continueGameplay()
				Audio.playSound("button")
			} else if node == manager.menuBtn.node || node == manager.menuBtn.label {
				triggeredBtn = manager.menuBtn
				manager.menuBtn.push()
				reloadScene()
				Audio.playSound("button")
			} else if node == manager.advertBtn.node || node == manager.advertBtn.label {
				triggeredBtn = manager.advertBtn
				manager.advertBtn.push()
				NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showAd"), object: nil)
				Audio.playSound("button")
			}
		}
	}
	
	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
		guard let st = sliderTouch else { return }
		let touchX = st.location(in: cam.node).x
		let halfLine = manager.line.size.width / 2
		if touchX > -halfLine && touchX < halfLine {
			manager.slider.position.x = touchX + offset
			player.turn(left: player.node.position.x >= manager.slider.position.x)
		}
	}
	
	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		if manager.soundButton.pressed {
			manager.soundButton.pressed = false
			manager.soundButton.node.texture = manager.soundButton.textures[SOUND_ENABLED ? 0 : 2].px()
		} else if let st = sliderTouch, touches.contains(st) {
			sliderTouch = nil
			manager.slider.texture = SKTexture(imageNamed: "slider-0").px()
		} else if triggeredBtn != nil {
			triggeredBtn.release()
			triggeredBtn = nil
		}
	}
	
	override func update(_ currentTime: TimeInterval) {
		cam.shake(1.25, 5, 0, 1.5)
		
		// Cam, player anim
		if started {
			cam.node.position.y = lerp(cam.node.position.y, player.node.position.y, cam.easing)
			if player.isFalling() && player.currentAnim != player.fallAnim {
				player.runAnim(player.fallAnim)
			}
		} else { started = player.node.position.y > 0 }
		
		// Platforms
		if started && !ended {
			platforms.create(player.node.position.y)
			platforms.remove(bounds.minY)
			if player.node.position.y < minY { finish() }
		}
		
		// Player movement, trail, score, bounds
		if !stopped {
			movement = lerp(player.node.position.x, manager.slider.position.x, 0.27)
			player.node.position.x = movement
			
			bounds.minX = -frame.size.width/2 + cam.node.position.x
			bounds.minY = cam.node.frame.minY - frame.height/2
			bounds.maxX = frame.size.width/2 + cam.node.position.x
			bounds.maxY = cam.node.frame.maxY + frame.height/2
			if bounds.minY > minY { minY = bounds.minY }
			if trail.distance() > 60 { trail.create(in: world) }
			
			let score = Int(player.node.position.y/100) + bonusPoints
			if score > 0 && score > Int(player.score) {
				manager.setScore(score, platforms.stage)
				player.setScore(score)
				if score%100==0 { platforms.stage.upgrade(score/100) }
			}
		}
		
		// Clouds
		if !stopped && !ended {
			if bg.canBuild(player.node.position.y, started) { world.addChild(bg.create()) }
			if fg.canBuild(player.node.position.y, started) { world.addChild(fg.create()) }
			bg.dispose(); bg.move()
			fg.dispose(); fg.move()
		}
		
		if ended { cam.node.position.x = lerp(cam.node.position.x, player.node.position.x, cam.easing/5) }
	}
	
	// Imp
	
	func continueGameplay() {
		manager.menuVisiblity(false)
		player.revive()
		ended = false
		player.push(power: 170)
		platforms.highestY = player.node.position.y + 100
		cam.node.run(SKAction.moveTo(x: 0, duration: 1))
		minY = self.player.node.position.y - 100
		
		let scale = SKAction.scale(to: 0.95, duration: 1)
		let rotate = SKAction.rotate(toAngle: 0, duration: 1)
		scale.timingMode = .easeOut; rotate.timingMode = .easeInEaseOut
		let go = SKAction.run {
			self.physicsWorld.speed = 1
			self.world.isPaused = false
		}
		
		cam.shake(50, 6, 6, 0.055)
		cam.node.run(SKAction.group([scale, go, rotate]))
		manager.show(manager.line, manager.hpBorder, manager.gameScoreLbl)
		manager.hide(manager.continueLbl)
	}
	
	private func reloadScene() {
		let physics = SKAction.run {
			self.player.node.physicsBody!.velocity = CGVector(dx: 0, dy: 50)
			self.physicsWorld.gravity = CGVector(dx: 0, dy: -18)
			self.physicsWorld.speed = 1
			self.world.isPaused = false
			let a = SKAction.fadeIn(withDuration: 0.4)
			a.timingMode = .easeIn
			self.fade.run(a)
		}
		let load = SKAction.run {
			GameScene.restarted = true
			let defaults = UserDefaults.standard
			var wq : Int = defaults.value(forKey: "wooden") as? Int ?? 0
			wq += Int(self.manager.woodLbl.text!)!
			defaults.set(wq, forKey: "wooden")
			var bq : Int = defaults.value(forKey: "bronze") as? Int ?? 0
			bq += Int(self.manager.bronzeLbl.text!)!
			defaults.set(bq, forKey: "bronze")
			var gq : Int = defaults.value(forKey: "golden") as? Int ?? 0
			gq += Int(self.manager.goldLbl.text!)!
			defaults.set(gq, forKey: "golden")
			
			let scene = GameScene(size: self.frame.size)
			scene.scaleMode = SKSceneScaleMode.aspectFill
			self.view!.presentScene(scene)
			self.removeAllChildren()
		}
		run(SKAction.sequence([SKAction.group([SKAction.wait(forDuration: 0.4), physics]), load ]))
	}

	private func finish(_ wait: TimeInterval = 0) {
		ended = true
		Audio.playSound("hurt")
		let action = SKAction.run {
			self.sliderTouch = nil
			self.manager.menuVisiblity(true)
			self.platforms.clean()
				
			let scale = SKAction.scale(to: 0.25, duration: 1)
			scale.timingMode = SKActionTimingMode.easeIn
			scale.speed = 3
			
			let angle: CGFloat = self.player.node.position.x > 0 ? -0.3 : 0.3
			let rotate = SKAction.rotate(toAngle: angle, duration: 1)
			rotate.timingMode = SKActionTimingMode.easeInEaseOut
			rotate.speed = 0.6
			
			let stop = SKAction.run {
				self.physicsWorld.speed = 0
				self.world.isPaused = true
			}
			let scaleStop = SKAction.sequence([scale, stop])
			self.cam.node.run(SKAction.group([scaleStop, rotate]))
			self.manager.hide(self.manager.line, self.manager.hpBorder, self.manager.gameScoreLbl)
		}
		
		run(SKAction.sequence([SKAction.wait(forDuration: wait), action]))
	}
	
	private func pickItem(_ item: Item, _ platform: Platform) {
		var name = item.node.name!.dropLast(4)
		name = name.first!.uppercased() + name.dropFirst()
		name += "Particles"
		
		let pos = CGPoint(x: platform.node.position.x + item.node.position.x,
											y: platform.node.position.y + item.node.position.y)
		manager.createEmitter(world, String(name), pos)
		
		switch item {
		case is Coin:
			manager.createLbl(world, platform.node.position)
			Audio.playSound("coin-pickup")
		case is Food:
			Audio.playSound("food-pickup")
		default: break
		}
		platforms.removeItem(item, from: platform)
	}
	
	private func lerp(_ start: CGFloat, _ end: CGFloat, _ percent: CGFloat) -> CGFloat {
			return start + percent * (end - start)
	}
	
	private func extractNode(_ node: String, _ contact: SKPhysicsContact) -> SKNode? {
			return contact.bodyA.node!.name!.contains(node) ?
				contact.bodyA.node : contact.bodyB.node
	}
	
	static func saveDefaults() {
		UserDefaults.standard.set(GameScene.ownedSkins, forKey: "ownedSkins")
		UserDefaults.standard.set(GameScene.skinIndex, forKey: "skinIndex")
		UserDefaults.standard.set(SOUND_ENABLED, forKey: "soundEnabled")
	}
	
	func loadDefaults() {
		GameScene.ownedSkins = UserDefaults.standard.value(forKey: "ownedSkins") as? [Int] ?? [0]
		GameScene.skinIndex = UserDefaults.standard.value(forKey: "skinIndex") as? Int ?? 0
		SOUND_ENABLED = UserDefaults.standard.value(forKey: "soundEnabled") as? Bool ?? true
	}
	
	// AdMob
	
	@objc func watchedAd() {
		manager.advertBtn.node.isHidden = true
		manager.continueLbl.isHidden = false
		manager.menuBtn.node.position = manager.advertBtn.node.position
		manager.show(manager.line)
	}
	
	@objc func dismissedAd() { manager.hide(manager.advertBtn.node) }
}

struct ButtonStruct {
	var node: SKSpriteNode
	var pressed = false
	var textures: [SKTexture]
}
