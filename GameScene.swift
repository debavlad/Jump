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
    
    var character: Character!
    
    var sky, platform, line, slider, button, black: SKSpriteNode!
    var scaleUp, scaleDown, moveUpFade: SKAction!
    var pauseTexture, playTexture: SKTexture!
    var sliderTouch: UITouch!
    
    var movement: CGFloat!
    var manager: Manager!
    var sliderIsTriggered = false, gameIsPaused = false
    
    
    override func didMove(to view: SKView) {
        character = Character(childNode(withName: "character")!)
        
        setNodes()
        setPhysics()
        setAnimations()
        manager = Manager(startY: platform.position.y, frameMinY: -frame.height)
        setCamera()
    }
    
    fileprivate func setNodes() {
        sky = childNode(withName: "sky")?.pixelate()
        platform = childNode(withName: "platform")?.pixelate()
        line = childNode(withName: "line")?.pixelate()
        slider = childNode(withName: "slider")?.pixelate()
        button = childNode(withName: "pause")?.pixelate()
        black = childNode(withName: "black")?.pixelate()
        playTexture = SKTexture(imageNamed: "continue").pixelate()
        pauseTexture = SKTexture(imageNamed: "pause").pixelate()
        
        slider.position.x = character.getX()
        movement = character.getX()
        
        worldNode = SKNode()
        character.set(parent: worldNode)
        addChild(worldNode)
    }
    
    fileprivate func setCamera() {
        cam = SKCameraNode()
        camera = cam
        
        sky.move(toParent: cam)
        slider.move(toParent: cam)
        line.move(toParent: cam)
        button.move(toParent: cam)
        black.move(toParent: cam)
        
        addChild(cam)
    }
    
    fileprivate func setAnimations() {
        // For slider
        scaleUp = SKAction.scale(to: 1.3, duration: 0.1)
        scaleDown = SKAction.scale(to: 1, duration: 0.1)
        
        // For label
        let moveUp = SKAction.move(to: CGPoint(x: 70, y: 140), duration: 1)
//        moveUp.timingMode = SKActionTimingMode.easeOut
        let fade = SKAction.fadeAlpha(to: 0, duration: 1)
//        fade.timingMode = SKActionTimingMode.easeOut
        let remove = SKAction.run { self.removeFromParent() }
        
        let group = SKAction.group([moveUp, fade, remove])
//        group.timingMode = SKActionTimingMode.easeOut
        moveUpFade = group
    }
    
    fileprivate func setPhysics() {
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVector(dx: 0, dy: -21)
        
        platform.physicsBody?.categoryBitMask = Categories.woodenPlatform
        platform.physicsBody?.contactTestBitMask = 0
    }
    

    func didBegin(_ contact: SKPhysicsContact) {
        if !character.isDead {
            // If character touched an item somehow
            let collision: UInt32 = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
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
                    let dust = getParticles(filename: "DustParticles", targetNode: nil)
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
                    character.push(power: 70)
                } else if collision == Collisions.characterAndStone {
                    character.decreaseHp(by: 5)
                    character.push(power: 80)
                }
            }
        }
    }
    
    fileprivate func getParticles(filename: String, targetNode: SKNode?) -> SKEmitterNode {
        let particles = SKEmitterNode(fileNamed: filename)!
        particles.name = String()
        if filename != "DustParticles" {
            particles.targetNode = targetNode
        }
        
        return particles
    }
    
    fileprivate func pickItemUp(item: SKNode, isCoin: Bool, platform: SKNode) {
        let wasTouched = item.userData?.value(forKey: "wasTouched") as! Bool
        
        if wasTouched {
            // food and coin suffixes are both 4 length
            var name = item.name!.dropLast(4)
            // getting particles file name
            name = name.first!.uppercased() + name.dropFirst()
            name += "Particles"
            
            let particles = getParticles(filename: String(name), targetNode: platform)
            particles.position = item.position
            particles.zPosition = 3
            particles.particleZPosition = 3
            add(emitter: particles, to: platform)
            
            if isCoin {
                let label = getLabel(text: "+1")
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
    
    fileprivate func getLabel(text: String) -> SKLabelNode {
        let label = SKLabelNode(text: text)
        label.name = String()
        label.fontName = "DisposableDroidBB"
        label.fontColor = UIColor.white
        label.fontSize = 64
        label.position = CGPoint(x: 70, y: 70)
        label.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 50, height: 20))
        label.physicsBody?.collisionBitMask = 0
        label.zPosition = 30
        return label
    }
    

    override func update(_ currentTime: TimeInterval) {
        // Setting camera and player positions
        camera!.position.y = lerp(start: (camera?.position.y)!, end: character.getY(), percent: 0.065)
        movement = lerp(start: character.getX(), end: slider.position.x, percent: 0.2)
        character.set(x: movement)
        
        // Creating clouds and platforms
        if manager.bgClouds.canCreate(playerY: character.getY()) {
            let cloud = manager.bgClouds.instantiate()
            worldNode.addChild(cloud)
            manager.bgClouds.remove(minY: cam.frame.minY - frame.height/1.95)
        }
        
        if manager.fgClouds.canCreate(playerY: character.getY()) {
            let cloud = manager.fgClouds.instantiate()
            worldNode.addChild(cloud)
            manager.fgClouds.remove(minY: cam.frame.minY - frame.height/1.95)
        }
        
        if manager.platforms.canCreate(playerY: character.getY()) {
            let platform = manager.platforms.instantiate()
            worldNode.addChild(platform)
            manager.platforms.remove(minY: cam.frame.minY - frame.height/1.95)
        }
    }
    
    func lerp(start: CGFloat, end: CGFloat, percent: CGFloat) -> CGFloat {
        return start + percent * (end - start)
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let node = atPoint(touch.location(in: self))
        
        if node == slider {
            sliderIsTriggered = true
            sliderTouch = touch
            slider.run(scaleUp)
        } else if node == button {
            sliderIsTriggered = false
            gameIsPaused ? setGameState(isPaused: false) : setGameState(isPaused: true)
        }
    }
    
    fileprivate func setGameState(isPaused: Bool) {
        if isPaused {
            button.texture = playTexture
            physicsWorld.speed = 0
            black.alpha = 0.3
        } else {
            button.texture = pauseTexture
            physicsWorld.speed = 1
            black.alpha = 0
        }
        worldNode.isPaused = !worldNode.isPaused
        gameIsPaused = !gameIsPaused
        line.isHidden = !line.isHidden
        slider.isHidden = !slider.isHidden
    }
    
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if sliderIsTriggered, let st = sliderTouch {
            let touchX = st.location(in: self).x
            let halfLine = line.size.width / 2
            
            if touchX > -halfLine && touchX < halfLine {
                slider.position.x = touchX
                if character.getX() < slider.position.x {
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
            slider.run(scaleDown)
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

extension SKNode {
    func pixelate() -> SKSpriteNode {
        let node = self as! SKSpriteNode
        node.texture?.filteringMode = .nearest
        return node
    }
}

extension SKTexture {
    func pixelate() -> SKTexture {
        self.filteringMode = .nearest
        return self
    }
}
