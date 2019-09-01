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
    private var cam: Camera!
    private var manager: Manager!
    private var player: Player!
    private var trail: Trail!
    static var restarted: Bool = false
    
    private var world: SKNode!
    private var sliderMsg, doorMsg: Message!
    private var fade: SKSpriteNode!
    private var cloudFactory: CloudFactory!
    private var platformFactory: PlatformFactory!
    
    private var movement, offset, minY: CGFloat!
    private var sliderTouch: UITouch?
    private var triggeredBtn: Button!
    private var started = false, stopped = false, ended = false
    private var bounds: Bounds!
    
    
    override func didMove(to view: SKView) {
        // to-do: rewrite hardcoded cgsize
        fade = SKSpriteNode(color: .black, size: CGSize(width: 754, height: 1334))
        fade.alpha = GameScene.restarted ? 1 : 0
        fade.zPosition = 25
        
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVector(dx: 0, dy: -23)
        
        cam = Camera(scene: self)
        cam.node.addChild(fade)
        
        world = SKNode()
        manager = Manager(scene: self, world: world)
        manager.show(nodes: manager.line)
        
        player = Player(world.childNode(withName: "Character")!)
        player.turn(left: true)
        
        sliderMsg = Message(text: "START THE GAME", position: CGPoint(x: 35, y: 70))
        manager.slider.addChild(sliderMsg.node)
        
        doorMsg = Message(text: "CHANGE THE SKIN", position: CGPoint(x: -50, y: 100))
        doorMsg.flip(scale: 0.75)
        manager.door.addChild(doorMsg.node)
        
        addChild(world)
        trail = Trail(player: player.node)
        trail.create(in: world)
        
        platformFactory = PlatformFactory(world: world, 125...200, frame.height/2)
        cloudFactory = CloudFactory(frame: frame, world: world)
        bounds = Bounds()
        minY = player.y
        
        manager.slider.position.x = player.x
        movement = player.x
        cam.node.setScale(0.75)
        
        if GameScene.restarted {
            fade.run(SKAction.fadeOut(withDuration: 0.4))
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if player.alive {
            let col: UInt32 = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
            
            if col == Collision.playerFood || col == Collision.playerCoin {
                if let node = extract(node: "item", from: contact) {
                    let item = platformFactory.find(item: node)
                    item?.wasTouched = true
                }
            }
            
            minY = platformFactory.collection.isEmpty ? player.y : platformFactory.lowestY()
            
            if player.fallingDown() && col == Collision.playerPlatform {
                player.animate(player.landAnim)
                trail.create(in: world, scale: 30)
                manager.addEmitter(to: world, filename: "DustParticles", position: contact.contactPoint)
                
                let node = extract(node: "platform", from: contact)!
                let platform = platformFactory.find(platform: node)
                
                player.harm(by: platform.damage)
                if player.alive {
                    player.push(power: platform.power)
                } else {
                    player.push(power: 70)
                    finish(wait: 0.7)
                }
                
                if platform.hasItems() {
                    for item in platform.items {
                        if item.wasTouched {
                            switch item {
                            case is Coin:
                                pick(item: item, platform: platform)
                            case is Food:
                                player.heal(by: (item as! Food).energy)
                                pick(item: item, platform: platform)
                            default:
                                return
                            }
                        }
                    }
                }
                
                if platform.node.name!.contains("sand") {
                    platform.fall(contactX: contact.contactPoint.x)
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
        cam.shake(amplitude: 1, amount: 5, step: 0, duration: 2)
        if !stopped {
            movement = lerp(start: player.x, end: manager.slider.position.x, percent: 0.25)
            player.x = movement
            
            if trail.distance() > 50 && !ended {
                trail.create(in: world)
            }
            
            bounds.minX = -frame.size.width/2 + cam.x
            bounds.minY = cam.minY - frame.height/2
            bounds.maxX = frame.size.width/2 + cam.x
            bounds.maxY = cam.maxY + frame.height/2
        }
        
        if started {
            cam.y = lerp(start: cam.y, end: player.y, percent: cam.easing)
            
            if player.fallingDown() {
                if player.currentAnim != player.fallAnim {
                    player.animate(player.fallAnim)
                }
                if player.node.physicsBody!.velocity.dy < -2000 {
                    player.node.physicsBody!.velocity.dy = -2000
                }
            }
            
            if !ended {
                platformFactory.create(playerY: player.y)
                platformFactory.remove(minY: bounds.minY)
                
                if player.y < minY {
                    finish(wait: 0)
                }
            }
        } else if !started && !ended {
            started = player.y > 0
        }
        
        if ended {
            cam.x = lerp(start: cam.x, end: player.x, percent: cam.easing/3)
        }
        
        if !world.isPaused {
            cloudFactory.create(playerY: player.y, started: started)
            cloudFactory.bounds = bounds
            cloudFactory.remove()
            cloudFactory.move()
        }
        
        manager.removeLabels(minY: cam.minY - frame.height/2)
        manager.removeEmitters(minY: cam.minY - frame.height/2)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let node = atPoint(touch.location(in: self))
        
        if !started {
            if node == manager.slider {
                sliderTouch = touch
                offset = manager.slider.position.x - sliderTouch!.location(in: cam.node).x
                manager.slider.texture = SKTexture(imageNamed: "slider-1").pixelated()
                
                let push = SKAction.run {
                    self.player.push(power: 170)
                    self.cam.shake(amplitude: 50, amount: 6, step: 6, duration: 0.055)
                    let scale = SKAction.scale(to: 1.0, duration: 1)
                    scale.timingMode = SKActionTimingMode.easeIn
                    self.cam.node.run(scale)
                    //                self.manager.hide(nodes: self.player.message!.node)
                }
                player.node.removeAllActions()
                manager.show(nodes: manager.line, manager.hpBorder, manager.pauseBtn)
                run(push)
                manager.hide(nodes: doorMsg.node, sliderMsg.node)
                
            } else if node == manager.door {
                
                
                manager.door.run(manager.doorAnim)
                manager.hide(nodes: doorMsg.node, manager.line)
            }
        }
        else if started && !ended {
            if node == manager.slider {
                sliderTouch = touch
                offset = manager.slider.position.x - sliderTouch!.location(in: cam.node).x
                manager.slider.texture = SKTexture(imageNamed: "slider-1").pixelated()
            } else if node == manager.pauseBtn {
                sliderTouch = nil
                stopped ? gameState(paused: false) : gameState(paused: true)
            }
        }
        else if ended {
            if node == manager.menuBtn.node || node == manager.menuBtn.label {
                manager.menuBtn.state(pushed: true)
                triggeredBtn = manager.menuBtn
                restart()
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let st = sliderTouch {
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
            sliderTouch = nil
            manager.slider.texture = SKTexture(imageNamed: "slider-0").pixelated()
        }
        else if triggeredBtn != nil {
            triggeredBtn.state(pushed: false)
            triggeredBtn = nil
        }
    }
    
    
    private func restart() {
        let wait = SKAction.wait(forDuration: 0.6)
        let physics = SKAction.run {
            self.player.node.physicsBody!.velocity = CGVector(dx: 0, dy: 50)
            self.physicsWorld.gravity = CGVector(dx: 0, dy: -18)
            self.physicsWorld.speed = 1
            self.world.isPaused = false
            self.fade.run(SKAction.fadeIn(withDuration: 0.6))
        }
        let act = SKAction.run {
            GameScene.restarted = true
            let scene = GameScene(size: self.frame.size)
            scene.scaleMode = SKSceneScaleMode.aspectFill
            self.view!.presentScene(scene)
            self.removeAllChildren()
        }
        run(SKAction.sequence([SKAction.group([wait, physics]), act ]))
    }
    
    private func finish(wait: TimeInterval) {
        let wait = SKAction.wait(forDuration: wait)
        let action = SKAction.run {
            self.sliderTouch = nil
            self.manager.switchUI()
            
            let scale = SKAction.scale(to: 0.4, duration: 1)
            scale.timingMode = SKActionTimingMode.easeIn
            scale.speed = 3
            
            let angle: CGFloat = self.player.x > 0 ? -0.3 : 0.3
            let rotate = SKAction.rotate(toAngle: angle, duration: 1)
            rotate.timingMode = SKActionTimingMode.easeInEaseOut
            rotate.speed = 0.6
            
            let stop = SKAction.run {
                self.physicsWorld.speed = 0
                self.world.isPaused = true
            }
            
            let scaleStop = SKAction.sequence([scale, stop])
            self.cam.node.run(SKAction.group([scaleStop, rotate]))
            self.manager.hide(nodes: self.manager.line, self.manager.hpBorder, self.manager.pauseBtn)
            self.ended = true
        }
        run(SKAction.sequence([wait, action]))
    }
    
    private func pick(item: Item, platform: Platform) {
        // breaditem; goldenitem
        var name = item.node.name!.dropLast(4)
        // bread; golden
        name = name.first!.uppercased() + name.dropFirst()
        // Bread; Golden
        name += "Particles"
        // BreadParticles; GoldenParticles
        
        let pos = CGPoint(x: platform.node.position.x + item.node.position.x, y: platform.node.position.y + item.node.position.y)
        manager.addEmitter(to: world, filename: String(name), position: pos)
        if item is Coin {
            manager.addLabel(to: world, position: platform.node.position)
        }
        platform.remove(item: item)
    }
    
    private func lerp(start: CGFloat, end: CGFloat, percent: CGFloat) -> CGFloat {
        return start + percent * (end - start)
    }
    
    private func extract(node: String, from contact: SKPhysicsContact) -> SKNode? {
        return contact.bodyA.node!.name!.contains(node) ? contact.bodyA.node : contact.bodyB.node
    }
    
    private func gameState(paused: Bool) {
        if paused {
            manager.pauseBtn.texture = manager.playTexture
            physicsWorld.speed = 0
            manager.darken.alpha = 0.3
        } else {
            manager.pauseBtn.texture = manager.pauseTexture
            physicsWorld.speed = 1
            manager.darken.alpha = 0
        }
        
        stopped = paused
        world.isPaused = paused
        manager.line.isHidden = paused
        manager.slider.isHidden = paused
    }
}
