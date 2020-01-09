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
//import GoogleMobileAds

class GameScene: SKScene, SKPhysicsContactDelegate {
	private var cam: Camera!
	private var manager: SceneManager!
	private var player: Player!
	private var trail: Trail!
	private var cloudFactory: CloudFactory!
	private var platformFactory: PlatformFactory!
	private var sliderTip, doorTip: Tip!
	static var restarted = false
	
	static var skinIndex: Int!
	static var ownedSkins: [Int]!
	var ptsOffset = 0
	var arrayOfPlayers = [AVAudioPlayer]()
	
	private var world: SKNode!
	private var fade: SKSpriteNode!
	private var movement, offset, minY: CGFloat!
	private var sliderTouch: UITouch?
	private var triggeredBtn: Button!
	private var (started, stopped, ended) = (false, false, false)
	
	var doorOpens = false
	
	func continueGameplay() {
		run(SKAction.run {
//			self.manager.finishMenu(visible: false)
			self.manager.menuVisiblity(false)
			self.player.revive()
			self.ended = false
			self.player.push(power: 170)
			self.platformFactory.highestY = self.player.node.position.y + 100
			
			self.cam.node.run(SKAction.moveTo(x: 0, duration: 1))
			self.minY = self.player.node.position.y - 100
			
			let scale = SKAction.scale(to: 0.95, duration: 1)
			let rotate = SKAction.rotate(toAngle: 0, duration: 1)
			scale.timingMode = .easeOut
			rotate.timingMode = .easeOut
			
			let go = SKAction.run {
				self.physicsWorld.speed = 1
				self.world.isPaused = false
			}
			
			self.cam.node.run(SKAction.group([scale, go, rotate]))
			self.manager.show(self.manager.line, self.manager.hpBorder, self.manager.pauseBtn,self.manager.gameScoreLbl)
			self.manager.hide(self.manager.continueLbl)
		})
	}
	
	
	override func didMove(to view: SKView) {
		loadData()
		
		fade = SKSpriteNode(color: .black, size: frame.size)
		fade.alpha = GameScene.restarted ? 1 : 0
		fade.zPosition = 25
		
		physicsWorld.contactDelegate = self
		physicsWorld.gravity = CGVector(dx: 0, dy: -23.5)
		
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
		
		platformFactory = PlatformFactory(world, frame.height/2, 125...200)
		cloudFactory = CloudFactory(frame, world)
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
		
//		NotificationCenter.default.addObserver(self, selector: #selector(GameScene.adWatchedUI), name: NSNotification.Name(rawValue: "adWatchedUI"), object: nil)
//		NotificationCenter.default.addObserver(self, selector: #selector(GameScene.adDismissed), name: NSNotification.Name(rawValue: "adDismissed"), object: nil)
		GSAudio.sharedInstance.playSound(soundFileName: "wind")
	}
	
	
	func didBegin(_ contact: SKPhysicsContact) {
		if !player.isAlive { return }
		let col: UInt32 = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
		if let node = extractNode("item", contact), col == Collision.playerFood || col == Collision.playerCoin {
			platformFactory.findItem(node).wasTouched = true
		}
		
		if !(player.isFalling() && col == Collision.playerPlatform) { return }
		player.runAnim(player.landAnim)
		trail.create(in: world, 30.0)
		manager.createEmitter(world, "DustParticles", contact.contactPoint)
		
		let node = extractNode("platform", contact)!
		let platform = platformFactory.findPlatform(node)
		DispatchQueue.global(qos: .background).async {
			let audioName = "\(platform.type)-footstep"
			GSAudio.sharedInstance.playSounds(soundFileNames: audioName, "wind")
		}
		
		if platform.hasItems() {
			cam.shake(35, 1, 0, 0.12)
			
			for item in platform.items {
				if !item.wasTouched { continue }
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
			let power: CGFloat = Skins[GameScene.skinIndex].name == "ninja" ? CGFloat(platform.power) * 1.125 : CGFloat(platform.power)
			player.push(power: Int(power))
		} else {
			player.push(power: 70)
			finish(0.75)
		}
		
		if platform.type == .sand {
			platform.fall(contact.contactPoint.x)
		}
	}
	
	override func update(_ currentTime: TimeInterval) {
		cam.shake(1.25, 5, 0, 1.5)
		
		if started {
			cam.node.position.y = lerp(cam.node.position.y, player.node.position.y, cam.easing)
			if player.isFalling() && player.currentAnim != player.fallAnim {
				player.runAnim(player.fallAnim)
			}
		} else { started = player.node.position.y > 0 }
		
		if started && !ended {
			platformFactory.create(player.node.position.y)
//			if platformFactory.canBuild(player.node.position.y) { platformFactory.create() }
			platformFactory.remove(bounds.minY)
			if player.node.position.y < minY { finish() }
		}
		
		
		if !stopped {
			movement = lerp(player.node.position.x, manager.slider.position.x, 0.27)
			player.node.position.x = movement
			if let tmp = platformFactory.lowestY(), player.node.position.y > tmp { minY = tmp }
			if trail.distance() > 60 { trail.create(in: world) }
			
			let score = Int(player.node.position.y/100) + ptsOffset
			if score > 0 && score > Int(player.score) {
				manager.setScore(score, platformFactory.stage)
				player.setScore(score)
				if score%100 == 0 && manager.stageBorder.alpha != 0 {
					platformFactory.stage.upgrade(score/100)
					platformFactory.stage.setStageLabels(btm: manager.btmStageLbl, top: manager.topStageLbl)
				}
			}
			
			bounds.minX = -frame.size.width/2 + cam.node.position.x
			bounds.minY = cam.node.frame.minY - frame.height/2
			bounds.maxX = frame.size.width/2 + cam.node.position.x
			bounds.maxY = cam.node.frame.maxY + frame.height/2
		}
		
		if !stopped && !ended {
			cloudFactory.create(player.node.position.y, started)
			cloudFactory.remove()
			cloudFactory.move()
		}
		
		
		if ended { cam.node.position.x = lerp(cam.node.position.x, player.node.position.x, cam.easing/5) }
		manager.disposeLabels(cam.node.frame.minY - frame.height/2)
		manager.disposeEmitters(cam.node.frame.minY - frame.height/2)
	}
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
			let touch = touches.first!
			let node = atPoint(touch.location(in: self))
			
			if !started {
					if node == manager.slider && !doorOpens {
							DispatchQueue.global(qos: .background).async {
									GSAudio.sharedInstance.playSounds(soundFileNames: "button", "wood-footstep", "wind")
							}
							sliderTouch = touch
							offset = manager.slider.position.x - sliderTouch!.location(in: cam.node).x
							manager.slider.texture = SKTexture(imageNamed: "slider-1").px()
							ptsOffset = Skins[GameScene.skinIndex].name == "bman" ? 100 : 0
							NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loadAd"), object: nil)
							
							let push = SKAction.run {
									self.player.push(power: 170)
									self.cam.shake(50, 6, 6, 0.055)
									let scale = SKAction.scale(to: 0.95, duration: 1.25)
									scale.timingMode = SKActionTimingMode.easeInEaseOut
									self.cam.node.run(scale)
							}
							player.node.removeAllActions()
							cloudFactory.faster()
							manager.show(manager.line, manager.hpBorder, manager.pauseBtn, manager.gameScoreLbl, manager.stageBorder)
							run(push)
							manager.hide(sliderTip.node, manager.w, manager.b, manager.g)
							doorTip.node.alpha = 0
							
					} else if node == manager.door {
							doorOpens = true
							DispatchQueue.global(qos: .background).async {
									GSAudio.sharedInstance.playSound(soundFileName: "door-open")
							}
							
							manager.door.run(manager.doorAnim)
							manager.hide(manager.line, manager.w, manager.b, manager.g)
							
							let scale = SKAction.scale(to: 0.025, duration: 0.6)
							scale.timingMode = SKActionTimingMode.easeInEaseOut
							
							let doorPos = CGPoint(x: manager.house.position.x + manager.door.frame.maxX, y: manager.house.position.y + manager.door.frame.minY)
							let move = SKAction.move(to: doorPos, duration: 0.6)
							move.timingMode = SKActionTimingMode.easeIn
							
							let wait = SKAction.wait(forDuration: 0.4)
							let fade = SKAction.run {
									let a = SKAction.fadeIn(withDuration: 0.4)
									a.timingMode = .easeIn
									self.fade.run(a)
							}
							let act = SKAction.run {
									let scene = ShopScene(size: self.frame.size)
									self.view!.presentScene(scene)
									self.removeAllChildren()
							}
							run(SKAction.sequence([SKAction.group([wait, fade]), act]))
							cam.node.run(SKAction.group([scale, move]))
					}
			}
			else if started && !ended {
					if node == manager.slider {
							DispatchQueue.global(qos: .background).async {
									GSAudio.sharedInstance.playSound(soundFileName: "button")
							}
							sliderTouch = touch
							offset = manager.slider.position.x - sliderTouch!.location(in: cam.node).x
							manager.slider.texture = SKTexture(imageNamed: "slider-1").px()
							gameState(paused: false)
					} else if node == manager.pauseBtn {
							sliderTouch = nil
							//playSound(type: .UI, audioName: "push-down")
							stopped ? gameState(paused: false) : gameState(paused: true)
							manager.line.isHidden = false
							manager.slider.isHidden = false
					}
			}
			else if ended {
					if node == manager.slider {
							DispatchQueue.global(qos: .background).async {
									GSAudio.sharedInstance.playSound(soundFileName: "button")
							}
							sliderTouch = touch
							offset = manager.slider.position.x - sliderTouch!.location(in: cam.node).x
							manager.slider.texture = SKTexture(imageNamed: "slider-1").px()
//                GameScene.adWatched = true
							continueGameplay()
					} else if node == manager.menuBtn.node || node == manager.menuBtn.label {
							DispatchQueue.global(qos: .background).async {
									GSAudio.sharedInstance.playSound(soundFileName: "button")
							}
							manager.menuBtn.push()
							//playSound(type: .UI, audioName: "push-down")
							triggeredBtn = manager.menuBtn
							restart()
					}
//					else if node == manager.advertBtn.node || node == manager.advertBtn.label {
//							DispatchQueue.global(qos: .background).async {
//									GSAudio.sharedInstance.playSound(soundFileName: "button")
//							}
//							manager.advertBtn.push()
//							triggeredBtn = manager.advertBtn
//							NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showAd"), object: nil)
//					}
			}
	}
	
	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
			if let st = sliderTouch {
					let touchX = st.location(in: cam.node).x
					let halfLine = manager.line.size.width / 2
					
					if touchX > -halfLine && touchX < halfLine {
							manager.slider.position.x = touchX + offset
							if player.node.position.x < manager.slider.position.x {
									player.turn(left: false)
							} else {
									player.turn(left: true)
							}
					}
			}
	}
	
	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
			if let st = sliderTouch, touches.contains(st) {
					sliderTouch = nil
					manager.slider.texture = SKTexture(imageNamed: "slider-0").px()
			}
			else if triggeredBtn != nil {
					triggeredBtn.release()
					triggeredBtn = nil
			}
	}
	
	
	func loadData() {
			let defaults = UserDefaults.standard
			GameScene.ownedSkins = defaults.value(forKey: "ownedSkins") as? [Int] ?? [0]
			GameScene.skinIndex = defaults.value(forKey: "skinIndex") as? Int ?? 0
	}
	
	static func saveData() {
			let defaults = UserDefaults.standard
			defaults.set(GameScene.ownedSkins, forKey: "ownedSkins")
			defaults.set(GameScene.skinIndex, forKey: "skinIndex")
	}
	
	private func restart() {
			let wait = SKAction.wait(forDuration: 0.4)
			let physics = SKAction.run {
					self.player.node.physicsBody!.velocity = CGVector(dx: 0, dy: 50)
					self.physicsWorld.gravity = CGVector(dx: 0, dy: -18)
					self.physicsWorld.speed = 1
					self.world.isPaused = false
					let a = SKAction.fadeIn(withDuration: 0.4)
					a.timingMode = .easeIn
					self.fade.run(a)
			}
			let act = SKAction.run {
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
			run(SKAction.sequence([SKAction.group([wait, physics]), act ]))
	}
	
	func getBounds() -> Bounds {
			bounds.minX = -frame.size.width/2 + cam.node.position.x
			bounds.minY = cam.node.frame.minY - frame.height/2
			bounds.maxX = frame.size.width/2 + cam.node.position.x
			bounds.maxY = cam.node.frame.maxY + frame.height/2
			return bounds
	}
	
	private func finish(_ wait: TimeInterval = 0) {
			ended = true
			GSAudio.sharedInstance.playAsync(soundFileName: "hurt")
//			manager.advertBtn.node.isHidden = false
			manager.menuBtn.node.position = CGPoint(x: 0, y: -500)
			let wait = SKAction.wait(forDuration: wait)
			let action = SKAction.run {
					self.sliderTouch = nil
//					self.manager.finishMenu(visible: true)
				self.manager.menuVisiblity(true)
					self.platformFactory.clean()
					
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
					self.manager.hide(self.manager.line, self.manager.hpBorder, self.manager.pauseBtn, self.manager.gameScoreLbl)
					self.ended = true
			}
			
			run(SKAction.sequence([wait, action]))
	}
	
	private func pickItem(_ item: Item, _ platform: Platform) {
			var name = item.node.name!.dropLast(4)
			name = name.first!.uppercased() + name.dropFirst()
			name += "Particles"
			
			let pos = CGPoint(x: platform.node.position.x + item.node.position.x, y: platform.node.position.y + item.node.position.y)
			manager.createEmitter(world, String(name), pos)
			
			switch item {
			case is Coin:
				manager.createLbl(world, platform.node.position)
//					manager.createLabel(world, platform.node.position)
					GSAudio.sharedInstance.playAsync(soundFileName: "coin-pickup")
			case is Food:
					GSAudio.sharedInstance.playAsync(soundFileName: "food-pickup")
			default:
					break
			}
			
			platformFactory.removeItem(item, from: platform)
	}
	
	private func lerp(_ start: CGFloat, _ end: CGFloat, _ percent: CGFloat) -> CGFloat {
			return start + percent * (end - start)
	}
	
	private func extractNode(_ node: String, _ contact: SKPhysicsContact) -> SKNode? {
			return contact.bodyA.node!.name!.contains(node) ? contact.bodyA.node : contact.bodyB.node
	}
	
	private func gameState(paused: Bool) {
			if paused {
					manager.pauseBtn.texture = manager.playTexture
					physicsWorld.speed = 0
					manager.blackSprite.alpha = 0.3
			} else {
					manager.pauseBtn.texture = manager.pauseTexture
					physicsWorld.speed = 1
					manager.blackSprite.alpha = 0
			}

			stopped = paused
			world.isPaused = paused
			manager.line.isHidden = paused
			manager.slider.isHidden = paused
	}
}
