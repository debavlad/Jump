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
	var blockFactory: BlockFactory!
	private var cam: Camera!
	private var manager: SceneManager!
	private var world: SKNode!
	private var player: Player!
	private var trail: Trail!
	private var triggeredBtn: Button!
	private var fade: SKSpriteNode!
	private var sliderTouch: UITouch?

	static var restarted = false
	private var started = false, stopped = false, ended = false
	private var movement, offset, minY: CGFloat!
	
	
	override func didMove(to view: SKView) {
		world = SKNode()
		blockFactory = BlockFactory(world)
		
		fade = SKSpriteNode(color: .black, size: frame.size)
		fade.alpha = GameScene.restarted ? 1 : 0
		fade.zPosition = 25
		
		physicsWorld.contactDelegate = self
		physicsWorld.gravity = CGVector(dx: 0, dy: -25)
		
		cam = Camera(self)
		cam.node.addChild(fade)
		cam.node.position.y = -80
		
		manager = SceneManager(self, world)
		manager.show(manager.controlLine)
		
		player = Player(world.childNode(withName: "Character")!)
		player.turn(left: true)
		
		addChild(world)
		trail = Trail(player.node, UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1))
		trail.create(in: world)
		
		bounds = Bounds()
		minY = player.node.position.y
		
		manager.slider.position.x = player.node.position.x
		movement = player.node.position.x
		cam.node.setScale(0.75)
		
		let fadeOut = SKAction.fadeOut(withDuration: 0.3)
		fadeOut.timingMode = .easeOut
		fade.run(fadeOut)
	}
	
	func didBegin(_ contact: SKPhysicsContact) {
		if !player.isAlive { return }
		let col: UInt32 = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
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
		if col == (Bit.player | Bit.food) || col == (Bit.player | Bit.coin) ||
			col == (Bit.player | Bit.potion) || col == (Bit.player | Bit.trampoline) {
			guard let node = extractNode("item", contact) else { return }
			if let item = blockFactory.findItem(node) {
				item.intersected = true
			}
		}
		else if player.isFalling() && col == Bit.player | Bit.platform {
			guard let node = extractNode("platform", contact) else { return }
			manager.addEmitter("Dust", world, contact.contactPoint)
			trail.create(in: world, 30.0)
			cam.shake(45, 1, 0, 0.125)
			
			let block = self.blockFactory.find(node)
			var power = CGFloat(block.power)
			if let items = block.items?.filter({ (item) -> Bool in return item.intersected }) {
				for item in items {
					switch item {
						case is Coin:
							manager.iconLabel.text = String(Int(manager.iconLabel.text!)! + 1)
						case is Food:
							player.adjustHealth((item as! Food).energy)
						case is Potion:
							let val = CGFloat(30) * ((item as! Potion).poisoned ? -1 : 1)
							player.adjustHealth(val)
						default: break
					}
					block.remove(item)
					manager.pick(item)
				}
			}
			
			player.adjustHealth(-block.damage)
			if player.isAlive {
				player.push(power, nullify: true)
			}
			if block.type == .Sand { block.fall(contact.contactPoint.x) }
			removeThingsLowerThan(bounds.minY)
		}
	}
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		let touch = touches.first!
		let node = atPoint(touch.location(in: self))
		
		if node == manager.slider && !ended {
			sliderTouch = touch
			offset = manager.slider.position.x - sliderTouch!.location(in: cam.node).x
			manager.slider.texture = SKTexture(imageNamed: "slider-1").px()
			
			if !started {
				player.node.removeAllActions()
				manager.show(manager.controlLine, manager.hpLine, manager.gameScoreLbl)
				manager.hide(manager.w)
				
				player.push(170, nullify: true)
				cam.shake(50, 6, 6, 0.055)
				let scale = SKAction.scale(to: 0.95, duration: 1.25)
				scale.timingMode = .easeInEaseOut
				cam.node.run(scale)
			}
		} else if ended && node == manager.menuBtn.node || node == manager.menuBtn.label {
			triggeredBtn = manager.menuBtn
			manager.menuBtn.push()
			reload()
		}
	}
	
	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
		guard let st = sliderTouch else { return }
		let touchX = st.location(in: cam.node).x
		let lineHalf = manager.controlLine.size.width / 2
		if touchX > -lineHalf && touchX < lineHalf {
			manager.slider.position.x = touchX + offset
			player.turn(left: player.node.position.x >= manager.slider.position.x)
		}
	}
	
	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		if let st = sliderTouch, touches.contains(st) {
			sliderTouch = nil
			manager.slider.texture = SKTexture(imageNamed: "slider-0").px()
		} else if triggeredBtn != nil {
			triggeredBtn.release()
			triggeredBtn = nil
		}
	}
	
	override func update(_ currentTime: TimeInterval) {
		cam.shake(1.25, 1, 0, 1.5)
		cam.shake(manager.overlay, 2, 1, 0, 0.8)
		if started {
			cam.node.position.y = lerp(cam.node.position.y, player.node.position.y, cam.easing)
			if player.isFalling() && player.anim != player.fallAnim {
				player.animate(player.fallAnim)
			}
		} else {
			started = player.node.position.y > 0
		}
		
		if started && !ended {
			if blockFactory.can(player.node.position.y) { blockFactory.produce() }
			blockFactory.dispose(bounds.minY)
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
			if trail.distance() > 80 { trail.create(in: world) }
			let s = Int(player.node.position.y/100)
			if s > manager.score {
				manager.updateScore(s)
				if s%100 == 0 {
					blockFactory.stage.upgrade(to: s/100)
				}
			}
		}
		
		if ended {
			cam.node.position.x = lerp(cam.node.position.x, player.node.position.x, cam.easing/3)
		}
	}
	
	
	func removeThingsLowerThan(_ minY: CGFloat) {
		manager.emitters.forEach { (e) in
			if e.position.y < minY {
				e.removeFromParent()
				manager.emitters.remove(e)
			}
		}
//		platforms.birds.forEach { (b) in
//			if b.node.position.y < minY {
//				b.node.removeFromParent()
//				platforms.birds.remove(b)
//			}
//		}
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
			wq += Int(self.manager.iconLabel.text!)!
			defaults.set(wq, forKey: "wooden")
			
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
//			self.player.node.children.first!.run(SKAction.fadeOut(withDuration: 1))
			self.manager.fadeMenu(true)
			let scale = SKAction.scale(to: 0.25, duration: 1)
			scale.timingMode = .easeIn; scale.speed = 3
			let rotate = SKAction.rotate(toAngle: self.player.node.position.x > 0 ? -0.3 : 0.3, duration: 1)
			rotate.timingMode = .easeInEaseOut; rotate.speed = 0.6
			let stop = SKAction.run {
				self.physicsWorld.speed = 0
				self.world.isPaused = true
			}
			
			self.cam.node.run(SKAction.group([SKAction.sequence([scale, stop]), rotate]))
			self.manager.hide(self.manager.controlLine, self.manager.hpLine, self.manager.gameScoreLbl)
		}
		run(SKAction.sequence([SKAction.wait(forDuration: delay), action]))
	}
	
	private func lerp(_ start: CGFloat, _ end: CGFloat, _ percent: CGFloat) -> CGFloat {
			return start + percent * (end - start)
	}
	
	private func extractNode(_ node: String, _ contact: SKPhysicsContact) -> SKNode? {
			return contact.bodyA.node!.name!.contains(node) ?
				contact.bodyA.node : contact.bodyB.node
	}
}
