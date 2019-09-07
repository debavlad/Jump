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
    private var cloudFactory: CloudFactory!
    private var platformFactory: PlatformFactory!
    private var sliderTip, doorTip: Tip!
    static var restarted = false, skinName = "farmer"
    
    private var world: SKNode!
    private var fade: SKSpriteNode!
    private var movement, offset, minY: CGFloat!
    private var sliderTouch: UITouch?
    private var triggeredBtn: Button!
    private var started = false, stopped = false, ended = false
    private var bounds: Bounds!
    
    
    override func didMove(to view: SKView) {
        fade = SKSpriteNode(color: .black, size: frame.size)
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
        
        sliderTip = Tip(text: "START THE GAME", position: CGPoint(x: 35, y: 70))
        manager.slider.addChild(sliderTip.node)
        
        doorTip = Tip(text: "CHANGE THE SKIN", position: CGPoint(x: -50, y: 100))
        doorTip.flip(scale: 0.75)
        manager.door.addChild(doorTip.node)
        
        addChild(world)
        trail = Trail(player: player.node)
        trail.create(in: world)
        
        platformFactory = PlatformFactory(parent: world, startY: frame.height/2, distance: 125...200)
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
            
            if player.falling() && col == Collision.playerPlatform {
                // Play animation and create trail line
                player.run(animation: player.landAnim)
                trail.create(in: world, scale: 30)
                manager.addEmitter(to: world, filename: "DustParticles", position: contact.contactPoint)
                
                // Define platform obj
                let node = extract(node: "platform", from: contact)!
                let platform = platformFactory.find(platform: node)
                
                // Pick items up
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
                
                // Harm and push
                player.harm(by: platform.damage)
                if player.alive {
                    player.push(power: platform.power)
                } else {
                    player.push(power: 70)
                    finish(wait: 0.7)
                }
                
                if platform.node.name!.contains("sand") {
                    platform.fall(contactX: contact.contactPoint.x)
                }
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        cam.shake(amplitude: 1, amount: 5, step: 0, duration: 2)
        
        if !stopped {
            movement = lerp(start: player.x, end: manager.slider.position.x, percent: 0.25)
            player.x = movement
            
            // Define death point
            if let lowestY = platformFactory.lowestY(), player.y > lowestY {
                minY = lowestY
            }
            
            // Create trail line
            if trail.distance() > 50 && !ended {
                trail.create(in: world)
            }
            
            // Set score
            if player.y/100 > 0 && player.y/100 > CGFloat(player.score) {
                manager.set(score: Int(player.y/100))
                player.set(score: Int(player.y/100))
            }
        }
        
        if started {
            cam.y = lerp(start: cam.y, end: player.y, percent: cam.easing)
            
            if player.falling() {
                if player.currAnim != player.fallAnim {
                    player.run(animation: player.fallAnim)
                }
                if player.node.physicsBody!.velocity.dy < -2000 {
                    player.node.physicsBody!.velocity.dy = -2000
                }
            }
            
            if !ended {
                _ = getBounds()
                if platformFactory.can(playerY: player.y) {
                    platformFactory.create()
                }
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
            cloudFactory.bounds = getBounds()
            cloudFactory.remove()
            cloudFactory.move()
        }
        
        manager.removeLabels(minY: cam.minY - frame.height/2)
        manager.removeEmitters(minY: cam.minY - frame.height/2)
    }
    
    func getBounds() -> Bounds {
        bounds.minX = -frame.size.width/2 + cam.x
        bounds.minY = cam.minY - frame.height/2
        bounds.maxX = frame.size.width/2 + cam.x
        bounds.maxY = cam.maxY + frame.height/2
        return bounds
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
                manager.show(nodes: manager.line, manager.hpBorder, manager.pauseBtn, manager.gameScore)
                run(push)
                manager.hide(nodes: sliderTip.node)
                doorTip.node.alpha = 0
                
            } else if node == manager.door {
                manager.door.run(manager.doorAnim)
                manager.hide(nodes: manager.line)
                
                let scale = SKAction.scale(to: 0.025, duration: 1)
                scale.timingMode = SKActionTimingMode.easeInEaseOut
                let move = SKAction.moveBy(x: 200, y: -300, duration: 1)
                move.timingMode = SKActionTimingMode.easeIn
                
                let wait = SKAction.wait(forDuration: 0.5)
                let fade = SKAction.run {
                    self.fade.run(SKAction.fadeIn(withDuration: 0.5))
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
                sliderTouch = touch
                offset = manager.slider.position.x - sliderTouch!.location(in: cam.node).x
                manager.slider.texture = SKTexture(imageNamed: "slider-1").pixelated()
            } else if node == manager.pauseBtn {
                sliderTouch = nil
                stopped ? gameState(paused: false) : gameState(paused: true)
            }
        }
        else if ended {
            if node == manager.menuBtn.node || node == manager.menuBtn.lbl {
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
            self.manager.hide(nodes: self.manager.line, self.manager.hpBorder, self.manager.pauseBtn, self.manager.gameScore)
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
        cam.shake(amplitude: 10, amount: 2, step: 4, duration: 0.08)
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
