//
//  GameScene.swift
//  Jump
//
//  Created by Vladislav Deba on 7/30/19.
//  Copyright © 2019 Vladislav Deba. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    private var world: SKNode!
    
    private var cam: Camera!
    private var manager: Manager!
    private var player: Player!
    
    private var platformFactory: PlatformFactory!
    private var cloudFactory: CloudFactory!
    
    private var movement, offset: CGFloat!
    private var sliderTouch: UITouch!
    private var sliderTriggered = false, started = false, stopped = false, ended = false
    private var bounds: Bounds!
    
    
    override func didMove(to view: SKView) {
        // Physics
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVector(dx: 0, dy: -23)
        
        // Camera
        cam = Camera(scene: self)
        
        // Nodes
        world = SKNode()
        player = Player(childNode(withName: "Character")!)
        manager = Manager(scene: self, world: world)
        player.setParent(world)
        addChild(world)
        
        platformFactory = PlatformFactory(world: world, 150, frame.height/2)
        cloudFactory = CloudFactory(frame: frame, world: world)
        
        bounds = Bounds()
        
        manager.slider.position.x = player.x
        movement = player.x
        cam.node.setScale(0.85)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if player.alive {
            let col: UInt32 = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
            
            if col == Collision.playerFood || col == Collision.playerCoin {
                let pos = extract(node: "item", from: contact)!.position
                let item = platformFactory.findItem(pos: pos)!
                item.wasTouched = true
            }
            
            if player.fallingDown() && col == Collision.playerPlatform {
                player.animate(player.landAnim)
                
                let node = extract(node: "platform", from: contact)!
                let platform = platformFactory.find(pos: node.position)
                
                manager.addParticles(to: world, filename: "DustParticles", pos: contact.contactPoint)
                
                if let item = platform.findItem(type: "food"), item.wasTouched {
                    player.heal(by: (item as! Food).energy)
                    pick(item: item, platform: platform)
                }
                
                if let item = platform.findItem(type: "coin"), item.wasTouched {
                    pick(item: item, platform: platform)
                }
                
                player.harm(by: platform.harm)
                if player.alive {
                    player.push(power: platform.power)
                } else {
                    player.push(power: 70)
                    manager.hideUI()
                    ended = true
                }
                
//                if platform.get().has(name: "sand") {
//                    let wait = SKAction.wait(forDuration: 0.12)
//                    let fall = SKAction.run {
//                        platform.get().physicsBody?.isDynamic = true
//                        platform.get().physicsBody?.collisionBitMask = 0
//                        platform.get().physicsBody?.categoryBitMask = 0
//                        platform.get().physicsBody?.contactTestBitMask = 0
//                    }
//                    run(SKAction.sequence([wait, fall]))
//                }
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        //        cam.shake(amplitude: 0.8, amount: 5, step: 0, duration: 1.5)
        if !stopped {
            movement = lerp(start: player.x, end: manager.slider.position.x, percent: 0.225)
            player.x = movement
            
            bounds.minX = frame.minX + cam.x
            bounds.minY = cam.minY - frame.height/2
            bounds.maxX = frame.maxX + cam.x
            bounds.maxY = cam.maxY + frame.height/2
            
            if player.fallingDown() && player.currentAnim != player.fallAnim {
                player.animate(player.fallAnim)
            }
        }
        
        if started {
            cam.y = lerp(start: cam.y, end: player.y, percent: cam.easing)
        }
        
        if !started && !ended {
            started = player.y > 0
        } else if started && !ended {
            platformFactory.create(playerY: player.y)
            platformFactory.remove(minY: bounds.minY)
        }
        
        if !world.isPaused {
            cloudFactory.create(playerY: player.y, started: started)
            cloudFactory.remove(bounds: bounds)
            cloudFactory.move()
        }
        
        manager.removeLabels(minY: cam.minY - frame.height/2)
        manager.removeParticles(minY: cam.minY - frame.height/2)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if started {
            let touch = touches.first!
            let node = atPoint(touch.location(in: self))
            
            if node == manager.slider {
                sliderTriggered = true
                sliderTouch = touch
                offset = manager.slider.position.x - sliderTouch.location(in: self).x
                
                manager.slider.texture = SKTexture(imageNamed: "slider-1").pixelated()
            } else if node == manager.button {
                sliderTriggered = false
                stopped ? setGameState(isPaused: false) : setGameState(isPaused: true)
            }
        } else {
            // if game was not started yet
            // sit anim, wait a lil bit and jump uppppp
            let sit = SKAction.run {
                self.player.node.texture = SKTexture(imageNamed: "prepare0").pixelated()
            }
            let wait = SKAction.wait(forDuration: 0.06)
            let push = SKAction.run {
                //                self.cam.shake(amplitude: 50, amount: 5, step: 10, duration: 0.04)
                self.player.push(power: 170)
                let scale = SKAction.scale(to: 1.0, duration: 1)
                scale.timingMode = SKActionTimingMode.easeOut
                self.cam.node.run(scale)
            }
            let group = SKAction.sequence([sit, wait, push])
            player.node.removeAllActions()
            manager.showUI()
            run(group)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if sliderTriggered, let st = sliderTouch {
            let touchX = st.location(in: cam.node).x
            let halfLine = manager.line.size.width / 2
            
            if touchX > -halfLine && touchX < halfLine {
                manager.slider.position.x = touchX + offset
                if player.x < manager.slider.position.x {
                    player.turn(left: false)
                } else {
                    player.turn(left: true)
                }
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let st = sliderTouch, touches.contains(st) {
            sliderTriggered = false
            manager.slider.texture = SKTexture(imageNamed: "slider-0").pixelated()
        }
    }
    
    
    private func pick(item: Item, platform: Platform) {
        // breaditem; goldenitem
        var name = item.node.name!.dropLast(4)
        // bread; golden
        name = name.first!.uppercased() + name.dropFirst()
        // Bread; Golden
        name += "Particles"
        // BreadParticles; GoldenParticles
        
//        let parentPos = item.node.parent!.position
        let itemPos = CGPoint(x: platform.pos.x + item.node.position.x, y: platform.pos.y + item.node.position.y)
        manager.addParticles(to: world, filename: String(name), pos: itemPos)
        
        if item is Coin {
            manager.addLabel(to: world, pos: platform.pos)
        }
//        platform.items.remove(item)
//        item.node.removeFromParent()
        platform.remove(item: item)
    }
    
    private func lerp(start: CGFloat, end: CGFloat, percent: CGFloat) -> CGFloat {
        return start + percent * (end - start)
    }
    
    private func extract(node: String, from contact: SKPhysicsContact) -> SKNode? {
        return contact.bodyA.node!.name!.contains(node) ? contact.bodyA.node : contact.bodyB.node
    }
    
    private func setGameState(isPaused: Bool) {
        if isPaused {
            manager.button.texture = manager.playTexture
            physicsWorld.speed = 0
            manager.darken.alpha = 0.3
        } else {
            manager.button.texture = manager.pauseTexture
            physicsWorld.speed = 1
            manager.darken.alpha = 0
        }
        
        stopped = isPaused
        world.isPaused = isPaused
        manager.line.isHidden = isPaused
        manager.slider.isHidden = isPaused
    }
}
