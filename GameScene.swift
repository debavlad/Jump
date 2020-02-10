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
	private var cam: Camera!
	private var world: SKNode!
	var blockFactory: BlockFactory!
	private var manager: SceneManager!
	private var triggeredBtn: Button!
	private var fade: SKSpriteNode!
	private var sliderTouch: UITouch?
	private var player: Player!
	private var trail: Trail!

	static var restarted = false
	private var started = false, stopped = false, ended = false
	private var movement, offset, minY: CGFloat!
	
	
	override func didMove(to view: SKView) {
		physicsWorld.contactDelegate = self
		physicsWorld.gravity = CGVector(dx: 0, dy: -27)
		
		fade = SKSpriteNode(color: .black, size: frame.size)
		fade.zPosition = 25
		cam = Camera(self)
		cam.node.addChild(fade)
		cam.node.position.y = -80
		cam.node.setScale(0.75)
		
		world = SKNode()
		addChild(world)
		bounds = Bounds()
		blockFactory = BlockFactory(world)
		manager = SceneManager(self, world)
		manager.show(manager.sliderPath)
		player = Player(world.childNode(withName: "Character")!)
		trail = Trail(player.node, UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1))
		trail.create(in: world)
		
		minY = player.node.position.y
		manager.slider.position.x = player.node.position.x
		movement = player.node.position.x
		
		let out = SKAction.fadeOut(withDuration: 0.3)
		out.timingMode = .easeOut
		fade.run(out)
		
		// loading empty.wav in order to preload other sounds
		world.run(SKAction.playSoundFileNamed("empty.wav", waitForCompletion: false))
		if Audio.shared.isEnabled {
			Audio.shared.start()
		}
	}
	
	func didBegin(_ contact: SKPhysicsContact) {
		if !player.alive { return }
		let col: UInt32 = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
		
		if col == Bit.player | Bit.bird {
			guard let node = extractNode("bird", contact) else { return }
			manager.addEmitter("Bird", world, node.position)
			player.push(15, nullify: false)
			player.adjustHealth(-20)
			cam.punch(50, 0.13)
			node.removeFromParent()
		} else if col == Bit.player | Bit.item {
			guard let node = extractNode("item", contact) else { return }
			if let item = blockFactory.findItem(node) {
				item.intersected = true
			}
		} else if col == Bit.player | Bit.platform && player.falling {
			guard let node = extractNode("platform", contact) else { return }
			manager.addEmitter("Dust", world, contact.contactPoint)
			trail.create(in: world, 30)
			Audio.shared.play("step.wav", node)
			
			let block = blockFactory.find(node)
			cam.punch(block.isEmpty() ? 40 : 60, 0.13)
			if let c = block.items?.first(where: { (i) -> Bool in return i is Coin }), c.intersected {
				Audio.shared.play("coin.wav", world)
				manager.iconLabel.text = String(Int(manager.iconLabel.text!)! + 1)
				block.remove(c); manager.pick(c)
			} else if let f = block.items?.first(where: { (i) -> Bool in return i is Food }), f.intersected {
				Audio.shared.play("food.wav", world)
				player.adjustHealth((f as! Food).energy)
				block.remove(f); manager.pick(f)
			}
			
			player.adjustHealth(-block.damage)
			if player.alive {
				player.push(block.power, nullify: true)
			} else {
				Audio.shared.play("death.wav", player.node)
			}
			
			if block.type == .Sand {
				block.fall(contact.contactPoint.x)
			}
			disposeLowerThan(bounds.minY)
		}
	}
	
	override func update(_ currentTime: TimeInterval) {
		cam.shake(1.25, 1, 0, 1.5)
		if started {
			cam.node.position.y = lerp(cam.node.position.y, player.node.position.y, cam.easing)
			if !manager.toRemove.isEmpty {
				manager.toRemove.filter({ $0.position.y < bounds.minY }).forEach({
					$0.removeFromParent()
					manager.toRemove.remove($0)
				})
			}
			
			if !ended {
				if player.node.position.y < minY {
					gameOver()
				} else if blockFactory.can(player.node.position.y) {
					blockFactory.produce()
				}
				blockFactory.dispose(bounds.minY)
			}
			
			if player.falling && player.anim != player.fallAnim {
				player.animate(player.fallAnim)
			}
		} else {
			started = player.node.position.y > 0
		}
		
		if !stopped {
			movement = lerp(player.node.position.x, manager.slider.position.x, 0.32)
			player.node.position.x = movement
			bounds.minY = cam.node.frame.minY - frame.height/2
			if bounds.minY > minY { minY = bounds.minY }
			if trail.distance() > 80 { trail.create(in: world) }
			let score = Int(player.node.position.y/100)
			if score > manager.score {
				manager.updateScore(score)
				if score%100 == 0 {
					Stage.shared.upgrade(to: score/100)
				}
			}
		}
		
		if ended {
			cam.node.position.x = lerp(cam.node.position.x, player.node.position.x, cam.easing/3)
		}
	}
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		let touch = touches.first!
		let node = atPoint(touch.location(in: self))
		if node == manager.slider && !ended {
			sliderTouch = touch
			offset = manager.slider.position.x - sliderTouch!.location(in: cam.node).x
			manager.slider.texture = SKTexture(imageNamed: "slider-1").px()
			Audio.shared.play("button.wav", node)
			
			if !started {
				player.node.removeAllActions()
				manager.show(manager.sliderPath, manager.hp, manager.curPtsLabel)
				manager.hide(manager.coinIcon, manager.soundStats)
				player.push(190, nullify: true)
				cam.shake(70, 6, 8, 0.055)
				Audio.shared.play("swoosh.wav", player.node)
				let scale = SKAction.scale(to: 0.95, duration: 1.25)
				scale.timingMode = .easeInEaseOut
				cam.node.run(scale)
			}
		} else if ended && node == manager.menuBtn.node || node == manager.menuBtn.label {
			Audio.shared.play("button.wav", node)
			triggeredBtn = manager.menuBtn
			manager.menuBtn.push()
			reloadScene()
		} else if !started {
			soundOnOff()
		}
	}
	
	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
		guard let st = sliderTouch else { return }
		let touchX = st.location(in: cam.node).x
		let lineHalf = manager.sliderPath.size.width / 2
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

	
	private func soundOnOff() {
		if Audio.shared.isEnabled {
			UserDefaults.standard.set(false, forKey: "soundState")
			manager.soundStats.text = "SOUND OFF"
			Audio.shared.stop()
		} else {
			UserDefaults.standard.set(true, forKey: "soundState")
			manager.soundStats.text = "SOUND ON"
			Audio.shared.start()
		}
		UserDefaults.standard.synchronize()
	}
	
	private func disposeLowerThan(_ minY: CGFloat) {
		manager.emitters.forEach( {
			if $0.position.y < minY {
				$0.removeFromParent()
				manager.emitters.remove($0)
			}
		})
	}
	
	private func reloadScene() {
		let enablePhysics = SKAction.run {
			self.player.node.physicsBody!.velocity = CGVector(dx: 0, dy: 50)
			self.physicsWorld.gravity = CGVector(dx: 0, dy: -18)
			self.physicsWorld.speed = 1
			self.world.isPaused = false
			let a = SKAction.fadeIn(withDuration: 0.4)
			a.timingMode = .easeIn
			self.fade.run(a)
		}
		let loadScene = SKAction.run {
			GameScene.restarted = true
			let scene = GameScene(size: self.frame.size)
			scene.scaleMode = SKSceneScaleMode.aspectFill
			self.view!.presentScene(scene)
			self.removeAllChildren()
		}
		run(SKAction.sequence([SKAction.group([SKAction.wait(forDuration: 0.4), enablePhysics]), loadScene ]))
	}

	private func gameOver(_ delay: TimeInterval = 0) {
		ended = true
		player.node.physicsBody?.contactTestBitMask = 0
		run(SKAction.sequence([
			SKAction.wait(forDuration: delay),
			SKAction.run {
				self.sliderTouch = nil
				self.manager.menu(true)
				let scale = SKAction.scale(to: 0.25, duration: 1)
				scale.timingMode = .easeIn; scale.speed = 3
				let rotate = SKAction.rotate(toAngle: self.player.node.position.x > 0 ? -0.3 : 0.3, duration: 1)
				rotate.timingMode = .easeInEaseOut; rotate.speed = 0.6
				let stop = SKAction.run {
					Audio.shared.play("gameover.wav", self.fade)
					self.physicsWorld.speed = 0
					self.world.isPaused = true
				}
				var coins = UserDefaults.standard.value(forKey: "coins") as? Int ?? 0
				coins += Int(self.manager.iconLabel.text!)!
				UserDefaults.standard.set(coins, forKey: "coins")
				
				self.player.lighting.run(SKAction.fadeOut(withDuration: 0.5))
				self.cam.node.run(SKAction.group([SKAction.sequence([scale, stop]), rotate]))
				self.manager.hide(self.manager.sliderPath, self.manager.hp, self.manager.curPtsLabel)
			}
		]))
	}
	
	private func lerp(_ start: CGFloat, _ end: CGFloat, _ percent: CGFloat) -> CGFloat {
			return start + percent * (end - start)
	}
	
	private func extractNode(_ node: String, _ contact: SKPhysicsContact) -> SKNode? {
			return contact.bodyA.node!.name!.contains(node) ?
				contact.bodyA.node : contact.bodyB.node
	}
}
