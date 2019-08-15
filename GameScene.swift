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
    var offset: CGFloat!
    
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
        if character.isAlive {
            let collision: UInt32 = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
            
            // If character touched an item somehow
            if collision == Collision.withFood || collision == Collision.withCoin {
                if let item = contact.bodyA.node!.name!.contains("item") ? contact.bodyA.node : contact.bodyB.node {
                    item.userData?.setValue(true, forKey: "wasTouched")
                }
            }
            
            // If character is on the platform
            if character.isFallingDown() {
                let platform = (contact.bodyA.node?.name == "platform" ? contact.bodyA.node : contact.bodyB.node)!
                
                // 1. Pick items up and increase hp if needed
                if collision == Collision.withPlatform {
                    let dust = manager.getParticles(filename: "DustParticles", targetNode: nil)
                    add(emitter: dust, to: platform)
                    
                    if let food = platform.getFoodNode() {
                        let energy = food.userData?.value(forKey: "energy") as! Int
                        character.heal(by: energy)
                        pick(item: food, platform: platform)
                    }
                    
                    if let coin = platform.getCoinNode() {
                        pick(item: coin, platform: platform)
                    }
                    
                    let power = platform.userData?.value(forKey: "power") as! Int
                    let harm = platform.userData?.value(forKey: "harm") as! Int
                    
                    character.harm(by: harm)
                    if character.isAlive {
                        character.push(power: power)
                    } else {
                        character.push(power: 65)
                        manager.hideUI()
                        gameEnded = true
                    }
                }
            }
        }
    }
    
    
    fileprivate func pick(item: SKNode, platform: SKNode) {
        let wasTouched = item.userData?.value(forKey: "wasTouched") as! Bool
        
        if wasTouched {
            // breadfood; goldencoin
            var name = item.name!.dropLast(4)
            // bread; golden
            name = name.first!.uppercased() + name.dropFirst()
            // Bread; Golden
            name += "Particles"
            // BreadParticles; GoldenParticles
            
            let particles = manager.getParticles(filename: String(name), targetNode: platform)
            particles.position = item.position
            add(emitter: particles, to: platform)
            
            let isCoin = item.userData?.value(forKey: "energy") == nil
            if isCoin {
                let label = manager.getLabel(text: "+1")
                platform.addChild(label)
                
                label.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 60))
                let rotate = CGFloat.random(in: -0.0005...0.0005)
                label.physicsBody?.applyAngularImpulse(rotate)
            }
            
            shakeCameraForItem(duration: 0.2)
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
        
        shakeCamera(duration: 0.2)
        
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
        }
        
        if manager.fgClouds.canCreate(playerY: character.getY(), gameStarted: gameStarted) {
            let cloud = manager.fgClouds.instantiate()
            worldNode.addChild(cloud)
        }
        
        if !gameIsPaused {
            let minX = -frame.width/2 + cam.position.x
            let minY = cam.frame.minY - frame.height/1.95
            let maxX = frame.width/2 + cam.position.x
            manager.fgClouds.remove(minX: minX, minY: minY, maxX: maxX)
            manager.bgClouds.remove(minX: minX, minY: minY, maxX: maxX)
            
            manager.bgClouds.move()
            manager.fgClouds.move()
        }
    }
    
    func shakeCamera(duration:Float) {
        let amplitudeX:CGFloat = 1.5
        let amplitudeY:CGFloat = 1.5
        let numberOfShakes = duration / 0.04
        var actionsArray:[SKAction] = []
        for _ in 1...Int(numberOfShakes) {
            // build a new random shake and add it to the list
            let moveX = CGFloat.random(in: -amplitudeX...amplitudeX)
            let moveY = CGFloat.random(in: -amplitudeY...amplitudeY)
//            let moveX = CGFloat(arc4random_uniform(UInt32(amplitudeX))) - amplitudeX / 2
//            let moveY = CGFloat(arc4random_uniform(UInt32(amplitudeY))) - amplitudeY / 2
            let shakeAction = SKAction.moveBy(x: moveX, y: moveY, duration: 2)
            shakeAction.timingMode = SKActionTimingMode.easeOut;
            actionsArray.append(shakeAction);
            actionsArray.append(shakeAction.reversed());
        }
        
        let actionSeq = SKAction.sequence(actionsArray);
        cam.run(actionSeq)
    }
    
    func shakeCameraForStart(duration:Float) {
        var amplitudeX:CGFloat = 40
        var amplitudeY:CGFloat = 40
        let numberOfShakes = 6
        var actionsArray:[SKAction] = []
        for _ in 1...Int(numberOfShakes) {
            // build a new random shake and add it to the list
//            let moveX = CGFloat.random(in: -amplitudeX...amplitudeX)
//            let moveY = CGFloat.random(in: -amplitudeY...amplitudeY)
            
            var rand = Bool.random()
            let moveX = rand ? -amplitudeX : amplitudeX
            rand = Bool.random()
            let moveY = rand ? -amplitudeY : amplitudeY
            
            amplitudeX = amplitudeX - 6
            amplitudeY = amplitudeY - 6
            
            let shakeAction = SKAction.moveBy(x: moveX, y: moveY, duration: 0.04)
            shakeAction.timingMode = SKActionTimingMode.easeOut;
            actionsArray.append(shakeAction);
            actionsArray.append(shakeAction.reversed());
        }
        
        let actionSeq = SKAction.sequence(actionsArray);
        cam.run(actionSeq)
    }
    
    func shakeCameraForItem(duration:Float) {
        var amplitudeX:CGFloat = 10
        var amplitudeY:CGFloat = 10
        let numberOfShakes = 2
        var actionsArray:[SKAction] = []
        for _ in 1...Int(numberOfShakes) {
            // build a new random shake and add it to the list
            //            let moveX = CGFloat.random(in: -amplitudeX...amplitudeX)
            //            let moveY = CGFloat.random(in: -amplitudeY...amplitudeY)
            
            var rand = Bool.random()
            let moveX = rand ? -amplitudeX : amplitudeX
            rand = Bool.random()
            let moveY = rand ? -amplitudeY : amplitudeY
            
            amplitudeX = amplitudeX - 4
            amplitudeY = amplitudeY - 4
            
            let shakeAction = SKAction.moveBy(x: moveX, y: moveY, duration: 0.08)
            shakeAction.timingMode = SKActionTimingMode.easeOut;
            actionsArray.append(shakeAction);
            actionsArray.append(shakeAction.reversed());
        }
        
        let actionSeq = SKAction.sequence(actionsArray);
        cam.run(actionSeq)
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
                offset = manager.slider.position.x - sliderTouch.location(in: self).x
                
                manager.slider.texture = SKTexture(imageNamed: "slider-1").pixelate()
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
            let wait = SKAction.wait(forDuration: 0.04)
            let push = SKAction.run {
                self.shakeCameraForStart(duration: 0.2)
                self.character.push(power: 170)
//                self.manager.line.isHidden = false
//                self.manager.button.isHidden = false
//                self.manager.slider.isHidden = false
            }
            let group = SKAction.sequence([sit, wait, push])
            character.node.removeAllActions()
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
                manager.slider.position.x = touchX + offset
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

            manager.slider.texture = SKTexture(imageNamed: "slider-0").pixelate()
//            let scaleDown = SKAction.scale(to: 1, duration: 0.1)
//            manager.slider.run(scaleDown)
        }
    }
}

extension SKNode {
    func getCoinNode() -> SKNode? {
        return self.children.first { (n) -> Bool in
            return n.name!.contains("item") && n.userData?.value(forKey: "energy") == nil
        }
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
