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
    var cam: SKCameraNode!
    var worldNode: SKNode!
    
    var manager: Manager!
    var character: Character!
    
    var movement: CGFloat!
    var sliderTouch: UITouch!
    var sliderIsTriggered = false, gameIsPaused = false, gameStarted = false, gameEnded = false
    
    
    override func didMove(to view: SKView) {
        // Physics
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVector(dx: 0, dy: -23)
        
        // Camera
        cam = SKCameraNode()
        camera = cam
        addChild(cam)
        
        // Nodes
        manager = Manager(scene: self)
        manager.setCamera(cam)
        character = Character(childNode(withName: "character")!)
        
        manager.slider.position.x = character.getX()
        movement = character.getX()
        
        worldNode = SKNode()
        character.setParent(worldNode)
        addChild(worldNode)
    }

    
    func didBegin(_ contact: SKPhysicsContact) {
        if !character.isDead {
            // If character touched an item somehow
            let collision: UInt32 = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
//            if collision == Collisions.characterAndGround {
//                character.push(power: 30)
//            }
            
            if collision == Collisions.characterAndCoin {
                if let coin = contact.bodyA.node!.name!.contains("coin") ? contact.bodyA.node : contact.bodyB.node {
                    coin.userData?.setValue(true, forKey: "wasTouched")
                }
            } else if collision == Collisions.characterAndFood {
                if let food = contact.bodyA.node!.name!.contains("food") ? contact.bodyA.node : contact.bodyB.node {
                    food.userData?.setValue(true, forKey: "wasTouched")
                }
            }
            
            // If character is on the platform
            if character.isFallingDown() {
                let platform = (contact.bodyA.node?.name == "platform" ? contact.bodyA.node : contact.bodyB.node)!
                
                // 1. Pick items up and increase hp if needed
                if collision == Collisions.characterAndWood || collision == Collisions.characterAndStone {
                    let dust = manager.getParticles(filename: "DustParticles", targetNode: nil)
                    add(emitter: dust, to: platform)
                    
                    if let coin = platform.children.first(where: { (n) -> Bool in
                        return n.name!.contains("coin")
                    }) { pickItemUp(item: coin, isCoin: true, platform: platform) }
                    
                    if let food = platform.children.first(where: { (n) -> Bool in
                        return n.name!.contains("food")
                    }) {
                        let energy = food.userData?.value(forKey: "energy") as! Int
                        character.increaseHp(by: energy)
                        pickItemUp(item: food, isCoin: false, platform: platform)
                    }
                }
                
                // 2. Decrease player's hp and push him up
                if collision == Collisions.characterAndWood {
                    character.decreaseHp(by: 2)
                    if character.getHp() > 0 {
                        character.push(power: 75)
                    } else {
                        character.push(power: 10)
                        gameEnded = true
                    }
                } else if collision == Collisions.characterAndStone {
                    character.decreaseHp(by: 5)
                    if character.getHp() > 0 {
                        character.push(power: 85)
                    } else {
                        character.push(power: 10)
                        gameEnded = true
                    }
                }
            }
        }
    }
    
    
    fileprivate func pickItemUp(item: SKNode, isCoin: Bool, platform: SKNode) {
        let wasTouched = item.userData?.value(forKey: "wasTouched") as! Bool
        
        if wasTouched {
            // food and coin suffixes are both 4 length
            var name = item.name!.dropLast(4)
            // getting particles file name
            name = name.first!.uppercased() + name.dropFirst()
            name += "Particles"
            
            let particles = manager.getParticles(filename: String(name), targetNode: platform)
            particles.position = item.position
            particles.zPosition = 3
            particles.particleZPosition = 3
            add(emitter: particles, to: platform)
            
            if isCoin {
                let label = manager.getLabel(text: "+1")
                platform.addChild(label)
                label.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 60))
                let imp = CGFloat.random(in: -0.0005...0.0005)
                label.physicsBody?.applyAngularImpulse(imp)
            }
            
            item.removeFromParent()
        }
    }
    
    fileprivate func add(emitter: SKEmitterNode, to parent: SKNode) {
        let add = SKAction.run { parent.addChild(emitter) }
        let duration = emitter.particleLifetime
        let wait = SKAction.wait(forDuration: TimeInterval(duration))
        
        // emitter is a child of platform, so when platform is removed, emitter too
        let remove = SKAction.run {
            if !self.gameIsPaused {
                emitter.removeFromParent()
            }
        }
        
        let sequence = SKAction.sequence([add, wait, remove])
        self.run(sequence)
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Setting camera and player positions
        movement = lerp(start: character.getX(), end: manager.slider.position.x, percent: 0.2)
        character.setX(movement)
        
        if gameStarted && !gameEnded {
            camera!.position.y = lerp(start: (camera?.position.y)!, end: character.getY(), percent: 0.065)
            
            
            if manager.platforms.canCreate(playerY: character.getY()) {
                let platform = manager.platforms.instantiate()
                worldNode.addChild(platform)
                manager.platforms.remove(minY: cam.frame.minY - frame.height/1.95)
            }
            
            
        } else if !gameStarted && !gameEnded {
            if character.getY() > 100 {
//                setCamera()
                gameStarted = true
            }
        }
        
        
        // Creating clouds and platforms
        if manager.bgClouds.canCreate(playerY: character.getY(), gameStarted: gameStarted) {
            let cloud = manager.bgClouds.instantiate()
            worldNode.addChild(cloud)
            if gameStarted {
                manager.bgClouds.remove(minY: cam.frame.minY - frame.height/1.95)
            }
        }
        
        if manager.fgClouds.canCreate(playerY: character.getY(), gameStarted: gameStarted) {
            let cloud = manager.fgClouds.instantiate()
            worldNode.addChild(cloud)
            if gameStarted {
                manager.fgClouds.remove(minY: cam.frame.minY - frame.height/1.95)
            }
        }
        
//        manager.bgClouds.move()
//        manager.fgClouds.move()
        
        // Creating clouds and platforms
//        if manager.bgClouds.canCreate(playerY: character.getY()) {
//            let cloud = manager.bgClouds.instantiate()
//            worldNode.addChild(cloud)
//            manager.bgClouds.remove(minY: cam.frame.minY - frame.height/1.95)
//        }
//
//        if manager.fgClouds.canCreate(playerY: character.getY()) {
//            let cloud = manager.fgClouds.instantiate()
//            worldNode.addChild(cloud)
//            manager.fgClouds.remove(minY: cam.frame.minY - frame.height/1.95)
//        }
//
//        if manager.platforms.canCreate(playerY: character.getY()) {
//            let platform = manager.platforms.instantiate()
//            worldNode.addChild(platform)
//            manager.platforms.remove(minY: cam.frame.minY - frame.height/1.95)
//        }
    }
    
    func lerp(start: CGFloat, end: CGFloat, percent: CGFloat) -> CGFloat {
        return start + percent * (end - start)
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if gameStarted {
            let touch = touches.first!
            let node = atPoint(touch.location(in: self))
            
            if node == manager.slider {
                sliderIsTriggered = true
                sliderTouch = touch
                
                let scaleUp = SKAction.scale(to: 1.3, duration: 0.1)
                manager.slider.run(scaleUp)
            } else if node == manager.button {
                sliderIsTriggered = false
                gameIsPaused ? setGameState(isPaused: false) : setGameState(isPaused: true)
            }
        } else {
            // if game was not started yet
            // sit anim, wait a lil bit and jump uppppp
            let sit = SKAction.run {
                self.character.setSitAnimation(index: 1)
            }
            let wait = SKAction.wait(forDuration: 0.09)
            let push = SKAction.run {
                self.character.push(power: 170)
                self.manager.line.isHidden = false
                self.manager.button.isHidden = false
                self.manager.slider.isHidden = false
            }
            let group = SKAction.sequence([sit, wait, push])
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
        
        gameIsPaused = isPaused
        worldNode.isPaused = isPaused
        manager.line.isHidden = isPaused
        manager.slider.isHidden = isPaused
    }
    
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if sliderIsTriggered, let st = sliderTouch {
            let touchX = st.location(in: self).x
            let halfLine = manager.line.size.width / 2
            
            if touchX > -halfLine && touchX < halfLine {
                manager.slider.position.x = touchX
                if character.getX() < manager.slider.position.x {
                    character.turn(left: false)
                } else {
                    character.turn(left: true)
                }
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let st = sliderTouch, touches.contains(st) {
            sliderIsTriggered = false
            
            let scaleDown = SKAction.scale(to: 1, duration: 0.1)
            manager.slider.run(scaleDown)
        }
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
