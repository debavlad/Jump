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
	var blockFactory: BlockFactory!
	var itemFactory: ItemFactory!
	
	private var cam: Camera!
	private var manager: SceneManager!
	private var bg, fg: CloudFactory!
//	private var platforms: PlatformFactory!
	private var world: SKNode!
	private var player: Player!
	private var trail: Trail!
	// ui
	private var sliderTip, doorTip: Tip!
	private var fade, progress: SKSpriteNode!
	private var sliderTouch: UITouch?
	private var triggeredBtn: Button!
	// raw
	static var restarted = false
	static var skinIndex: Int!
	static var ownedSkins: [Int]!
	var bonusPoints = 0, doorOpens = false
	private var started = false, stopped = false, ended = false
	private var movement, offset, minY: CGFloat!
	private var trampolineAnim: SKAction!
	
	
	override func didMove(to view: SKView) {
		world = SKNode()
		itemFactory = ItemFactory()
		blockFactory = BlockFactory(world, itemFactory)
		
		
		loadDefaults()
		fade = SKSpriteNode(color: .black, size: frame.size)
		fade.alpha = GameScene.restarted ? 1 : 0
		fade.zPosition = 25
		
		physicsWorld.contactDelegate = self
		physicsWorld.gravity = CGVector(dx: 0, dy: -24.5)
		
		cam = Camera(self)
		cam.node.addChild(fade)
		cam.node.position.y = -60

		progress = SKSpriteNode(imageNamed: "particle").px()
		progress.anchorPoint = CGPoint(x: 0, y: 1)
		progress.xScale = 0; progress.yScale = 12
		progress.position = CGPoint(x: frame.minX, y: frame.maxY)
		progress.colorBlendFactor = 1
		progress.zPosition = 16
		progress.color = UIColor.black
		cam.node.addChild(progress)
		
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
//		platforms = PlatformFactory(world, frame.height/2, 125...200)
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
		
		trampolineAnim = SKAction.animate(with: [SKTexture(imageNamed: "batut1"),
																						 SKTexture(imageNamed: "batut0")], timePerFrame: 0.1)
		blockFactory.produce(10)
	}
	
	func didBegin(_ contact: SKPhysicsContact) {
		if !player.isAlive { return }
		let col: UInt32 = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
//		if col == Collision.playerFood || col == Collision.playerCoin || col == Collision.playerTrampoline
//		|| col == Collision.playerPotion {
//			guard let node = extractNode("item", contact) else { return }
//			platforms.getItem(node)?.wasTouched = true
//		}
//		if col == Collision.playerBird {
//			guard let bird = extractNode("bird", contact) else { return }
//			manager.createEmitter(world, "BirdParticles", bird.position)
//			cam.shake(40, 1, 0, 0.12)
//			bird.removeFromParent()
//			if player.node.physicsBody!.velocity.dy >= 0 {
//				player.editHp(-20)
//				Audio.playSound("hurt")
//				player.push(10, nullify: false)
//			} else {
//				player.push(80, nullify: true)
//			}
//		}
		if player.isFalling() {
			if col == Collision.playerPlatform {
				guard let node = extractNode("platform", contact) else { return }
				manager.createEmitter(world, "Dust", contact.contactPoint)
				trail.create(in: world, 30.0)
				cam.shake(40, 1, 0, 0.125)
				let block = blockFactory.find(node)
				player.editHp(-block.damage)
				player.push(block.power, nullify: true)
			}
			else if col == Collision.playerFood {
				guard let node = extractNode("item", contact) else { return }
				let item = itemFactory.find(node)
				item.execute()
			}
		}
//		if col == Collision.playerPlatform && player.isFalling() {
//			guard let node = extractNode("platform", contact) else { return }
//			let block = blockFactory.find(node)
//			player.editHp(-block.damage)
//			player.push(block.power, nullify: true)
//		}
//			removeThingsLowerThan(bounds.minY)
//			player.animate(player.landAnim)
//			trail.create(in: world, 30.0)
//			manager.createEmitter(world, "DustParticles", contact.contactPoint)
//			guard let node = extractNode("platform", contact) else { return }
//			let platform = platforms.getPlatform(node)
//			Audio.playSounds("\(platform.type)-footstep", "wind")
//
//			let action = SKAction.scaleX(to: CGFloat(7.5) * (platforms.stage.current >= 1 ?
//				CGFloat(manager.score + 3 - platforms.stage.current*100) : CGFloat(manager.score + 3)),
//				y: 12, duration: 1)
//			action.timingMode = .easeOut
//			action.speed = 3
//			progress.run(action)
//
//			var power = CGFloat(platform.power)
//			if platform.hasItems() {
//				cam.shake(40, 1, 0, 0.125)
//				if let f = platform.getItem(Food.self) as? Food {
//					let e = CGFloat(f.energy) * (Skins[GameScene.skinIndex].name == "farmer" ? 1.25 : 1)
//					player.editHp(Int(e))
//					pick(f, platform)
//				}
//				if let c = platform.getItem(Coin.self) as? Coin {
//					pick(c, platform)
//					manager.collectCoin(c.currency)
//				}
//				if let t = platform.getItem(Trampoline.self) {
//					t.node.run(trampolineAnim)
//					power = 92
//				}
//				if let p = platform.getItem(Potion.self) as? Potion {
//					player.editHp(p.type == PotionType.red ? -player.health/2 : player.health/2)
//					pick(p, platform)
//				}
//			} else { cam.punch(30) }
//
//			player.editHp(-platform.damage)
//			if player.isAlive {
//				power *= Skins[GameScene.skinIndex].name == "ninja" ? 1.125 : 1
//				player.push(power: Int(power), nullify: true)
//			} else { end(0.5) }
//
//			if platform.type == .sand { platform.fall(contact.contactPoint.x) }
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
				player.push(170, nullify: true)
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
				revive()
				Audio.playSound("button")
			} else if node == manager.menuBtn.node || node == manager.menuBtn.label {
				triggeredBtn = manager.menuBtn
				manager.menuBtn.push()
				reload()
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
		cam.shake(1.25, 1, 0, 1.5)
		if started {
			cam.node.position.y = lerp(cam.node.position.y, player.node.position.y, cam.easing)
			if player.isFalling() && player.anim != player.fallAnim {
				player.animate(player.fallAnim)
			}
		} else {
			started = player.node.position.y > 0
		}
		
		if started && !ended {
//			platforms.create(player.node.position.y)
//			platforms.removeLowerThan(bounds.minY)
			if player.node.position.y < minY { end() }
		}
		
		if !stopped {
			movement = lerp(player.node.position.x, manager.slider.position.x, 0.28)
			player.node.position.x = movement
			bounds.minX = -frame.size.width/2 + cam.node.position.x
			bounds.minY = cam.node.frame.minY - frame.height/2
			bounds.maxX = frame.size.width/2 + cam.node.position.x
			bounds.maxY = cam.node.frame.maxY + frame.height/2
			if bounds.minY > minY { minY = bounds.minY }
			if trail.distance() > 75 { trail.create(in: world) }
			let s = Int(player.node.position.y/100) + bonusPoints
			if s > manager.score {
				manager.setScore(s)
//				if s%100 == 0 { platforms.stage.upgrade(s/100) }
			}
		}
		
		if !stopped && !ended {
			if bg.canSpawn(player.node.position.y, started) { world.addChild(bg.create()) }
			if fg.canSpawn(player.node.position.y, started) { world.addChild(fg.create()) }
			bg.dispose(); bg.move(); fg.dispose(); fg.move()
		}
		
		if ended {
			cam.node.position.x = lerp(cam.node.position.x, player.node.position.x, cam.easing/4)
		}
	}
	
	// Imp
	
	func removeThingsLowerThan(_ minY: CGFloat) {
		manager.emitters.forEach { (e) in
			if e.position.y < minY {
				e.removeFromParent()
				manager.emitters.remove(e)
			}
		}
		manager.labels.forEach { (l) in
			if l.position.y < minY {
				l.removeFromParent()
				manager.labels.remove(l)
			}
		}
//		platforms.birds.forEach { (b) in
//			if b.node.position.y < minY {
//				b.node.removeFromParent()
//				platforms.birds.remove(b)
//			}
//		}
	}
	
	private func revive() {
		manager.menuVisiblity(false)
		player.revive()
		ended = false
		player.push(170, nullify: true)
//		platforms.highestY = player.node.position.y + 100
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
	
	private func reload() {
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

	private func end(_ delay: TimeInterval = 0) {
		ended = true
		let action = SKAction.run {
			self.sliderTouch = nil
			self.manager.menuVisiblity(true)
			let scale = SKAction.scale(to: 0.25, duration: 1)
			scale.timingMode = .easeIn; scale.speed = 3
			let rotate = SKAction.rotate(toAngle: self.player.node.position.x > 0 ? -0.3 : 0.3, duration: 1)
			rotate.timingMode = .easeInEaseOut; rotate.speed = 0.6
			let stop = SKAction.run {
				self.physicsWorld.speed = 0
				self.world.isPaused = true
			}
			
			self.cam.node.run(SKAction.group([SKAction.sequence([scale, stop]), rotate]))
			self.manager.hide(self.manager.line, self.manager.hpBorder, self.manager.gameScoreLbl)
		}
		run(SKAction.sequence([SKAction.wait(forDuration: delay), action]))
	}
	
	private func pick(_ item: Item, _ platform: Platform) {
		let key = "\(item.node.name!.dropLast(4))"
		var name = ""
		switch item {
			case is Coin: name = "CoinParticles"
			case is Food: name = "FoodParticles"
			case is Potion: name = "PotionParticles"
			default: break
		}
		let em = getEmitter(name, key, CGPoint(x: platform.node.position.x + item.node.position.x,
																					 y: platform.node.position.y + item.node.position.y))
		manager.createEmitter(world, em)
		if item is Coin {
			manager.createLbl(world, platform.node.position)
			Audio.playSound("coin-pickup")
		} else if item is Food {
			Audio.playSound("food-pickup")
		}
//		platforms.removeItem(item, from: platform)
	}
	
	private func getEmitter(_ name: String, _ key: String, _ pos: CGPoint) -> SKEmitterNode {
		let em = SKEmitterNode(fileNamed: name)!
		em.particleColorSequence = nil
		em.particleColor = dict[key]!
		em.particleBlendMode = key == "gold" || key == "yellow" ? .add : .alpha
		em.position = pos
		return em
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
