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
    static var counter: Int = 0
    
    private var world: SKNode!
    private var black: SKSpriteNode!
    private var cloudFactory: CloudFactory!
    private var platformFactory: PlatformFactory!
    
    private var movement, offset, minY: CGFloat!
    private var sliderTouch: UITouch!
    private var triggeredBtn: Button!
    private var sliderTriggered = false, started = false, stopped = false, ended = false
    private var bounds: Bounds!
    
    override func didMove(to view: SKView) {
        // Physics
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVector(dx: 0, dy: -23)
        
        black = SKSpriteNode(color: .black, size: CGSize(width: 754, height: 1334))
        black.zPosition = 25
        black.alpha = 0
        
        // Camera
        cam = Camera(scene: self)
        cam.node.addChild(black)
        
        if GameScene.counter > 0 {
            black.alpha = 1
            black.run(SKAction.fadeOut(withDuration: 0.4))
        }
        
        // Nodes
        world = SKNode()
        manager = Manager(scene: self, world: world)
        
        manager.show(nodes: manager.line)
        
        player = Player(world.childNode(withName: "Character")!)
        let text = "HOLD THE SLIDER"
        let msg = Message(scale: 2, text: text)
        msg.loc = Location.right
        player.display(msg: msg)
        player.turn(left: true)
        msg.move()
        
        player.setParent(world)
        addChild(world)
        trail = Trail(player: player.node)
        trail.create(in: world)
        
        platformFactory = PlatformFactory(world: world, 150, frame.height/2)
        cloudFactory = CloudFactory(frame: frame, world: world)
        
        bounds = Bounds()
        minY = player.y
        
        manager.slider.position.x = player.x
        movement = player.x
        cam.node.setScale(0.85)
//        player.node.addChild(msg.node)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if player.alive {
            let col: UInt32 = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
            
            if col == Collision.playerFood || col == Collision.playerCoin {
                let pos = extract(node: "item", from: contact)!.position
                let item = platformFactory.findItem(pos: pos)!
                item.wasTouched = true
            }
            
            minY = platformFactory.collection.count > 0 ? platformFactory.defineMinY() : player.y
            
            if player.fallingDown() && col == Collision.playerPlatform {
                player.animate(player.landAnim)
                
                trail.create(in: world, scale: 30)
                
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
                    endGame(wait: 0.7)
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
    
    private func endGame(wait: TimeInterval) {
        let wait = SKAction.wait(forDuration: wait)
        let action = SKAction.run {
            self.sliderTriggered = false
            self.manager.gameOver()
            
            let scale = SKAction.scale(to: 0.4, duration: 1)
            scale.speed = 3
            scale.timingMode = SKActionTimingMode.easeIn
            let x: CGFloat = self.player.x > 0 ? -0.3 : 0.3
            let angle = SKAction.rotate(toAngle: x, duration: 1)
            angle.speed = 0.6
            angle.timingMode = SKActionTimingMode.easeInEaseOut
            let stop = SKAction.run {
                self.physicsWorld.speed = 0
                self.world.isPaused = true
            }
            let seq = SKAction.sequence([scale, stop])
            self.cam.node.run(SKAction.group([seq, angle]))
            
//            self.manager.hideUI()
            self.manager.hide(nodes: self.manager.line, self.manager.hpBorder, self.manager.pauseBtn)
            self.ended = true
        }
        run(SKAction.sequence([wait, action]))
    }
    
    override func update(_ currentTime: TimeInterval) {
        cam.shake(amplitude: 1, amount: 5, step: 0, duration: 2)
        if !stopped {
//            movement = lerp(start: player.x, end: manager.slider.position.x, percent: 0.225)
            movement = lerp(start: player.x, end: manager.slider.position.x, percent: 0.25)
            player.x = movement
            
            if trail.distance() > 50 && !ended {
                trail.create(in: world)
            }
            
            bounds.minX = -frame.size.width/2 + cam.x
            bounds.minY = cam.minY - frame.height/2
            bounds.maxX = frame.size.width/2 + cam.x
            bounds.maxY = cam.maxY + frame.height/2
            
            if started && player.fallingDown() && player.currentAnim != player.fallAnim {
                player.animate(player.fallAnim)
            }
        }
        
        if player.node.physicsBody!.velocity.dy < -2000 {
            player.node.physicsBody!.velocity.dy = -2000
        }
        
        if started && player.y < minY && !ended {
            endGame(wait: 0)
        }
        
        if started {
            cam.y = lerp(start: cam.y, end: player.y, percent: cam.easing)
        }
        
        if ended {
            cam.x = lerp(start: cam.x, end: player.x, percent: cam.easing/3)
        }
        
        if !started && !ended {
            started = player.y > 0
        } else if started && !ended {
            platformFactory.create(playerY: player.y)
            platformFactory.remove(minY: bounds.minY)
        }
        
        if !world.isPaused {
            cloudFactory.create(playerY: player.y, started: started)
            cloudFactory.bounds = bounds
            cloudFactory.remove()
            cloudFactory.move()
        }
        
        manager.removeLabels(minY: cam.minY - frame.height/2)
        manager.removeParticles(minY: cam.minY - frame.height/2)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let node = atPoint(touch.location(in: self))
        
        if !started && node == manager.slider {
            sliderTriggered = true
            sliderTouch = touch
            offset = manager.slider.position.x - sliderTouch.location(in: cam.node).x
            manager.slider.texture = SKTexture(imageNamed: "slider-1").pixelated()
            
            let sit = SKAction.run {
                self.player.node.texture = SKTexture(imageNamed: "prepare0").pixelated()
            }
            let wait = SKAction.wait(forDuration: 0.06)
            let push = SKAction.run {
                self.player.push(power: 170)
                let scale = SKAction.scale(to: 1.0, duration: 1)
                scale.timingMode = SKActionTimingMode.easeIn
                self.cam.node.run(scale)
                self.manager.hide(nodes: self.player.msg!.node)
            }
            let seq = SKAction.sequence([sit, wait, push])
            player.node.removeAllActions()
            manager.show(nodes: manager.line, manager.hpBorder, manager.pauseBtn)
            run(seq)
        }
        else if started && !ended {
            if node == manager.slider {
                sliderTriggered = true
                sliderTouch = touch
                offset = manager.slider.position.x - sliderTouch.location(in: cam.node).x
                manager.slider.texture = SKTexture(imageNamed: "slider-1").pixelated()
            } else if node == manager.pauseBtn {
                sliderTriggered = false
                stopped ? setGameState(isPaused: false) : setGameState(isPaused: true)
            }
        }
        else if ended {
            if node == manager.backBtn.node || node == manager.backBtn.label {
                manager.backBtn.state(pushed: true)
                triggeredBtn = manager.backBtn
                backToMenu()
            }
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
        else if triggeredBtn != nil {
            triggeredBtn.state(pushed: false)
            triggeredBtn = nil
        }
    }
    
    private func backToMenu() {
        
        let wait = SKAction.wait(forDuration: 0.6)
        let physics = SKAction.run {
            self.player.node.physicsBody!.velocity = CGVector(dx: 0, dy: 50)
            self.physicsWorld.gravity = CGVector(dx: 0, dy: -18)
            self.physicsWorld.speed = 1
            self.world.isPaused = false
            self.black.run(SKAction.fadeIn(withDuration: 0.6))
        }
        let act = SKAction.run {
            GameScene.counter += 1
            let scene = GameScene(size: self.frame.size)
            scene.scaleMode = SKSceneScaleMode.aspectFill
            self.view!.presentScene(scene)
            self.removeAllChildren()
        }
        run(SKAction.sequence([SKAction.group([wait, physics]), act ]))
    }
    
    private func pick(item: Item, platform: Platform) {
        // breaditem; goldenitem
        var name = item.node.name!.dropLast(4)
        // bread; golden
        name = name.first!.uppercased() + name.dropFirst()
        // Bread; Golden
        name += "Particles"
        // BreadParticles; GoldenParticles
        
        let itemPos = CGPoint(x: platform.pos.x + item.node.position.x, y: platform.pos.y + item.node.position.y)
        manager.addParticles(to: world, filename: String(name), pos: itemPos)
        if item is Coin {
            manager.addLabel(to: world, pos: platform.pos)
        }
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
            manager.pauseBtn.texture = manager.playTexture
            physicsWorld.speed = 0
            manager.darken.alpha = 0.3
        } else {
            manager.pauseBtn.texture = manager.pauseTexture
            physicsWorld.speed = 1
            manager.darken.alpha = 0
        }
        
        stopped = isPaused
        world.isPaused = isPaused
        manager.line.isHidden = isPaused
        manager.slider.isHidden = isPaused
    }
}
