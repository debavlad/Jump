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
    
    var movement, offset: CGFloat!
    var sliderTouch: UITouch!
    var sliderTriggered = false, gameStarted = false, gamePaused = false, gameEnded = false
    
    
    override func didMove(to view: SKView) {
        // Physics
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVector(dx: 0, dy: -23)
        
        // Camera
        cam = Camera(scene: self)
        
        // Nodes
        player = Player(childNode(withName: "character")!)
        manager = Manager(scene: self)
        
        manager.slider.position.x = player.x
        movement = player.x
        
        world = SKNode()
        player.setParent(world)
        addChild(world)
        
        cam.node.setScale(0.85)
    }
    
    func extract(node: String, from contact: SKPhysicsContact) -> SKNode? {
        return contact.bodyA.node!.name!.contains(node) ? contact.bodyA.node : contact.bodyB.node
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
                let platform = extract(node: "platform", from: contact)!
                let dust = manager.getParticles(filename: "DustParticles")
                add(emitter: dust, pos: contact.contactPoint)
                
                if let food = platform.getFoodNode(), food.wasTouched()! {
                    let energy = food.userData?.value(forKey: "energy") as! Int
                    player.heal(by: energy)
                    pick(item: food, platform: platform)
                }
                if let coin = platform.getCoinNode(), coin.wasTouched()! {
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
                    gameEnded = true
                }
                
//                if platform.has(name: "sand") {
//                    let right = contact.contactPoint.x > platform.position.x ? true : false
//                    platform.physicsBody?.allowsRotation = true
//                    platform.physicsBody?.isDynamic = true
//                    platform.physicsBody?.collisionBitMask = 0
//                    platform.physicsBody?.categoryBitMask = 0
//                    platform.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
//                    platform.physicsBody?.applyImpulse(CGVector(dx: 0, dy: -20))
//                    platform.physicsBody?.applyAngularImpulse(right ? -1 : 1)
//
//                    for child in platform.children {
//                        child.move(toParent: world)
//                        child.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 20))
//                        child.physicsBody?.collisionBitMask = 0
//                        child.physicsBody?.categoryBitMask = 0
//                    }
//                }
            }
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
        
        let particles = manager.getParticles(filename: String(name))
        //            print(item.position)
        add(emitter: particles, pos: CGPoint(x: platform.position.x + item.position.x, y: platform.position.y + item.position.y))
        
        let isCoin = item.userData?.value(forKey: "energy") == nil
        if isCoin {
            let label = manager.getLabel(text: "+1")
            add(label: label, platform: platform)
        }
        
        cam.shake(amplitude: 10, amount: 2, step: 4, duration: 0.08)
        item.removeFromParent()
    }
    
    fileprivate func add(label: SKLabelNode, platform: SKNode) {
        label.position.x += platform.position.x
        label.position.y += platform.position.y
        world.addChild(label)
        label.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 60))
        let rotate = CGFloat.random(in: -0.0005...0.0005)
        label.physicsBody?.applyAngularImpulse(rotate)
    }
    
    fileprivate func add(emitter: SKEmitterNode, pos: CGPoint) {
        emitter.position = pos
        let add = SKAction.run { self.world.addChild(emitter) }
        let duration = emitter.particleLifetime
        let wait = SKAction.wait(forDuration: TimeInterval(duration))
        
        // emitter is a child of platform, so when platform is removed, emitter too
        let remove = SKAction.run {
            if !self.gamePaused {
                emitter.removeFromParent()
            }
        }
        
        let sequence = SKAction.sequence([add, wait])
        self.run(sequence)
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Setting camera and player positions
        movement = lerp(start: player.x, end: manager.slider.position.x, percent: 0.225)
        player.x = movement
        
        cam.shake(amplitude: 0.8, amount: 5, step: 0, duration: 1.5)
        
        if gameStarted && !gameEnded {
            cam.y = lerp(start: cam.y, end: player.y, percent: 0.065)
            if manager.platforms.canCreate(playerY: player.y) {
                let platform = manager.platforms.instantiate()
                world.addChild(platform.node)
            }
            manager.platforms.remove(minY: cam.minY - frame.height/2)
        } else if !gameStarted && !gameEnded {
            if player.y > 100 {
                gameStarted = true
            }
        }
        
        // Creating clouds and platforms
        if manager.bgClouds.canCreate(playerY: player.y, gameStarted: gameStarted) {
            let cloud = manager.bgClouds.generate()
            world.addChild(cloud)
        }
        
        if manager.fgClouds.canCreate(playerY: player.y, gameStarted: gameStarted) {
            let cloud = manager.fgClouds.generate()
            world.addChild(cloud)
        }
        
        if !gamePaused {
            let minX = frame.minX + cam.x
            let minY = cam.minY - frame.height/1.95
            let maxX = frame.maxX + cam.x
            
            manager.fgClouds.remove(minX: minX, minY: minY, maxX: maxX)
            manager.fgClouds.move()
            
            manager.bgClouds.remove(minX: minX, minY: minY, maxX: maxX)
            manager.bgClouds.move()
            
        }
    }
    
    func lerp(start: CGFloat, end: CGFloat, percent: CGFloat) -> CGFloat {
        return start + percent * (end - start)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if gameStarted {
            let touch = touches.first!
            let node = atPoint(touch.location(in: self))
            
            if node == manager.slider {
                sliderTriggered = true
                sliderTouch = touch
                offset = manager.slider.position.x - sliderTouch.location(in: self).x
                
                manager.slider.texture = SKTexture(imageNamed: "slider-1").pixelate()
            } else if node == manager.button {
                sliderTriggered = false
                gamePaused ? setGameState(isPaused: false) : setGameState(isPaused: true)
            }
        } else {
            // if game was not started yet
            // sit anim, wait a lil bit and jump uppppp
            let sit = SKAction.run {
                self.player.node.texture = SKTexture(imageNamed: "prepare0").pixelate()
            }
            let wait = SKAction.wait(forDuration: 0.04)
            let push = SKAction.run {
                self.cam.shake(amplitude: 50, amount: 5, step: 10, duration: 0.04)
                self.player.push(power: 170)
                let scale = SKAction.scale(to: 1.0, duration: 0.8)
                scale.timingMode = SKActionTimingMode.easeOut
                self.cam.node.run(scale)
            }
            let group = SKAction.sequence([sit, wait, push])
            player.node.removeAllActions()
            manager.showUI()
            run(group)
        }
    }
    
    fileprivate func setGameState(isPaused: Bool) {
        if isPaused {
            manager.button.texture = manager.playTexture
            physicsWorld.speed = 0
            manager.black.alpha = 0.3
        } else {
            manager.button.texture = manager.pauseTexture
            physicsWorld.speed = 1
            manager.black.alpha = 0
        }
        
        gamePaused = isPaused
        world.isPaused = isPaused
        manager.line.isHidden = isPaused
        manager.slider.isHidden = isPaused
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
            
            manager.slider.texture = SKTexture(imageNamed: "slider-0").pixelate()
        }
    }
}

extension SKNode {
    func getCoinNode() -> SKNode? {
        return self.children.first { (n) -> Bool in
            return n.name!.contains("item") && n.userData?.value(forKey: "energy") == nil
        }
    }
    
    func has(name: String) -> Bool {
        return self.name!.contains(name)
    }
    
    func wasTouched() -> Bool? {
        return (self.userData?.value(forKey: "wasTouched") as! Bool)
    }
    
    func getFoodNode() -> SKNode? {
        return self.children.first(where: { (n) -> Bool in
            return n.name!.contains("item") && n.userData?.value(forKey: "energy") != nil
        })
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
