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
    var world: SKNode!
    
    var cam: Camera!
    var manager: Manager!
    var player: Player!
    
    var platforms: Platforms!
    var clouds: CloudsManager!
    
    var movement, offset: CGFloat!
    var sliderTouch: UITouch!
    var sliderTriggered = false, started = false, stopped = false, ended = false
    var bounds: Bounds!
    
    
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
        
        platforms = Platforms(world: world, 150, frame.height/2)
        clouds = CloudsManager(frame: frame, world: world)
        
//        labels = Set<SKLabelNode>()
//        particles = Set<SKEmitterNode>()
        bounds = Bounds()
        
        manager.slider.position.x = player.x
        movement = player.x
        cam.node.setScale(0.85)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if player.alive {
            let col: UInt32 = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
            
            if col == Collision.playerFood || col == Collision.playerCoin {
                if let item = extract(node: "item", from: contact) {
                    item.userData?.setValue(true, forKey: "wasTouched")
                }
            }
            
            if player.fallingDown() && col == Collision.playerPlatform {
                player.animate(player.landAnim)
                
                let platform = extract(node: "platform", from: contact)!
                manager.addParticles(to: world, filename: "DustParticles", pos: contact.contactPoint)
                
                if let food = platform.foodNode(), food.wasTouched()! {
                    let energy = food.userData?.value(forKey: "energy") as! Int
                    player.heal(by: energy)
                    pick(item: food, platform: platform)
                }
                if let coin = platform.coinNode(), coin.wasTouched()! {
                    pick(item: coin, platform: platform)
                }
                
                let harm = platform.userData?.value(forKey: "harm") as! Int
                player.harm(by: harm)
                if player.alive {
                    let power = platform.userData?.value(forKey: "power") as! Int
                    player.push(power: power)
                } else {
                    player.push(power: 70)
                    manager.hideUI()
                    ended = true
                }
                
                if platform.has(name: "sand") {
                    let wait = SKAction.wait(forDuration: 0.12)
                    let fall = SKAction.run {
                        platform.physicsBody?.isDynamic = true
                        platform.physicsBody?.collisionBitMask = 0
                        platform.physicsBody?.categoryBitMask = 0
                        platform.physicsBody?.contactTestBitMask = 0
                    }
                    run(SKAction.sequence([wait, fall]))
                }
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
            platforms.create(playerY: player.y)
            platforms.remove(minY: bounds.minY)
        }
        
        if !world.isPaused {
            clouds.create(playerY: player.y, started: started)
            clouds.remove(bounds: bounds)
            clouds.move()
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
    
    
    fileprivate func pick(item: SKNode, platform: SKNode) {
        // breadfooditem; goldencoinitem
        var name = item.name!.dropLast(8)
        // bread; golden
        name = name.first!.uppercased() + name.dropFirst()
        // Bread; Golden
        name += "Particles"
        // BreadParticles; GoldenParticles
        
        manager.addParticles(to: world, filename: String(name), pos: CGPoint(x: platform.position.x + item.position.x, y: platform.position.y + item.position.y))
        
        let isCoin = item.userData?.value(forKey: "energy") == nil
        if isCoin {
            manager.addLabel(to: world, pos: platform.position)
        }
        
        //        cam.shake(amplitude: 20, amount: 3, step: 6, duration: 0.08)
        item.removeFromParent()
    }
    
    fileprivate func lerp(start: CGFloat, end: CGFloat, percent: CGFloat) -> CGFloat {
        return start + percent * (end - start)
    }
    
    fileprivate func extract(node: String, from contact: SKPhysicsContact) -> SKNode? {
        return contact.bodyA.node!.name!.contains(node) ? contact.bodyA.node : contact.bodyB.node
    }
    
    fileprivate func setGameState(isPaused: Bool) {
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

extension SKNode {
    func coinNode() -> SKNode? {
        return self.children.first { (n) -> Bool in
            return n.name!.contains("item") && n.userData?.value(forKey: "energy") == nil
        }
    }
    
    func foodNode() -> SKNode? {
        return self.children.first(where: { (n) -> Bool in
            return n.name!.contains("item") && n.userData?.value(forKey: "energy") != nil
        })
    }
    
    func has(name: String) -> Bool {
        return self.name!.contains(name)
    }
    
    func wasTouched() -> Bool? {
        return (self.userData?.value(forKey: "wasTouched") as! Bool)
    }
}

enum ParticlesType {
    case dust
    case wooden
    case bronze
    case gold
    
    case bread
    case meat
    case egg
    case chicken
    case cheese
}
