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
    var scaleUpAnimation, scaleDownAnimation, moveUpAnimation: SKAction!
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
        
        black.isHidden = true
        
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
        scaleUpAnimation = SKAction.scale(to: 1.3, duration: 0.1)
        scaleDownAnimation = SKAction.scale(to: 1, duration: 0.1)
        
        // For label
        let moveUp = SKAction.move(to: CGPoint(x: 70, y: 140), duration: 1)
        moveUp.timingMode = SKActionTimingMode.easeOut
        let dissapear = SKAction.fadeAlpha(to: 0, duration: 1)
        dissapear.timingMode = SKActionTimingMode.easeOut
        let remove = SKAction.run { self.removeFromParent() }
        
        let group = SKAction.group([moveUp, dissapear, remove])
        group.timingMode = SKActionTimingMode.easeOut
        moveUpAnimation = group
    }
    
    fileprivate func setPhysics() {
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVector(dx: 0, dy: -21)
        
        platform.physicsBody?.categoryBitMask = Categories.woodenPlatform
        platform.physicsBody?.contactTestBitMask = 0
    }
    

    func didBegin(_ contact: SKPhysicsContact) {
        if !character.isDead {
            // If character touched a coin somehow
            let collision: UInt32 = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
            if collision == Collisions.characterAndCoin {
                print(contact.bodyA.node!, contact.bodyB.node!)
                let coin = contact.bodyA.node!.name!.contains("coin") ? contact.bodyA.node! : contact.bodyB.node!
                
                coin.userData?.setValue(true, forKey: "wasTouched")
            } else if collision == Collisions.characterAndFood {
                let food = contact.bodyA.node!.name!.contains("food") ? contact.bodyA.node! : contact.bodyB.node!
                food.userData?.setValue(true, forKey: "wasTouched")
            }
            
            // If character jumped on a platform
            if character.isFallingDown() {
                let platform = (contact.bodyA.node?.name == "platform" ? contact.bodyA.node : contact.bodyB.node)!
                
                if collision == Collisions.characterAndWood {
                    let dust = getParticles(type: .dust, targetNode: nil)
                    add(dust, to: platform)
                    character.decreaseHp(by: 2)
                    character.push(power: 70)
                } else if collision == Collisions.characterAndStone {
                    let dust = getParticles(type: .dust, targetNode: nil)
                    add(dust, to: platform)
                    character.decreaseHp(by: 5)
                    character.push(power: 80)
                }
                
                // Picking up the coin
                if collision == Collisions.characterAndWood || collision == Collisions.characterAndStone {
                    
                    if let coin = platform.children.first(where: { (n) -> Bool in
                        return n.name!.contains("coin")
                    }) {
                        pickItemUp(item: coin, platform: platform)
                    }
                    
                    if let food = platform.children.first(where: { (n) -> Bool in
                        return n.name!.contains("food")
                    }) {
                        pickItemUp(item: food, platform: platform)
                    }
                }
            }
        }
    }
    
    fileprivate func getParticles(type: ParticlesType, targetNode: SKNode?) -> SKEmitterNode {
        let particles: SKEmitterNode!
        
        switch (type) {
        case .dust:
            particles = SKEmitterNode(fileNamed: "DustParticles")
        case .wooden:
            particles = SKEmitterNode(fileNamed: "WoodenParticles")!
        case .bronze:
            particles = SKEmitterNode(fileNamed: "BronzeParticles")!
        case .gold:
            particles = SKEmitterNode(fileNamed: "GoldenParticles")!
        case .bread:
            particles = SKEmitterNode(fileNamed: "BreadParticles")!
        case .cheese:
            particles = SKEmitterNode(fileNamed: "CheeseParticles")!
        case .chicken:
            particles = SKEmitterNode(fileNamed: "ChickenParticles")!
        case .egg:
            particles = SKEmitterNode(fileNamed: "EggParticles")!
        case .meat:
            particles = SKEmitterNode(fileNamed: "MeatParticles")!
        }
        
        particles.name = String()
        if type != .dust {
            particles.targetNode = targetNode
        }
        
        return particles
    }
    
    fileprivate func pickItemUp(item: SKNode, platform: SKNode) {
        let wasTouched = item.userData?.value(forKey: "wasTouched") as! Bool
        
        if wasTouched {
            var particles = SKEmitterNode()
            var label: SKLabelNode?
            
            if item.name!.contains("coin") {
                if item.name!.contains("wooden") {
                    particles = getParticles(type: .wooden, targetNode: platform)
                } else if item.name!.contains("bronze") {
                    particles = getParticles(type: .bronze, targetNode: platform)
                } else if item.name!.contains("golden") {
                    particles = getParticles(type: .gold, targetNode: platform)
                }
                
                label = getLabel(text: "+1")
            } else {
                if item.name!.contains("bread") {
                    particles = getParticles(type: .bread, targetNode: platform)
                    character.increaseHp(by: 15)
                } else if item.name!.contains("egg") {
                    particles = getParticles(type: .egg, targetNode: platform)
                    character.increaseHp(by: 5)
                } else if item.name!.contains("cheese") {
                    particles = getParticles(type: .cheese, targetNode: platform)
                    character.increaseHp(by: 10)
                } else if item.name!.contains("meat") {
                    particles = getParticles(type: .meat, targetNode: platform)
                    character.increaseHp(by: 25)
                } else {
                    particles = getParticles(type: .chicken, targetNode: platform)
                    character.increaseHp(by: 20)
                }
            }
            
            particles.position = item.position
            particles.zPosition = 3
            particles.particleZPosition = 3
            add(particles, to: platform)
            
            if let l = label {
                platform.addChild(l)
                l.run(moveUpAnimation)
            }
            
            item.removeFromParent()
        }
    }
    
    fileprivate func add(_ emitter: SKEmitterNode, to parent: SKNode) {
        let add = SKAction.run {
            parent.addChild(emitter)
        }
        
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
        label.fontName = "DisposableDroidBB"
        label.name = String()
        label.fontColor = UIColor.white
        label.blendMode = SKBlendMode.subtract
        label.position = CGPoint(x: 70, y: 70)
        label.fontSize = 64
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
        
        switch node {
        case slider:
            sliderIsTriggered = true
            sliderTouch = touch
            slider.run(scaleUpAnimation)
        case button:
            sliderIsTriggered = false
            if gameIsPaused {
                setGameState(isPaused: false)
            } else {
                setGameState(isPaused: true)
            }
        default:
            return
        }
    }
    
    fileprivate func setGameState(isPaused: Bool) {
        if isPaused {
            button.texture = playTexture
            worldNode.isPaused = true
            gameIsPaused = true
            physicsWorld.speed = 0
            line.isHidden = true
            slider.isHidden = true
            black.isHidden = false
        } else {
            button.texture = pauseTexture
            worldNode.isPaused = false
            gameIsPaused = false
            physicsWorld.speed = 1
            line.isHidden = false
            slider.isHidden = false
            black.isHidden = true
        }
    }
    
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if sliderIsTriggered {
            if let st = sliderTouch {
                let touchLocationX = st.location(in: self).x
                let halfLine = line.size.width / 2
                
                if touchLocationX > -halfLine && touchLocationX < halfLine {
                    slider.position.x = touchLocationX
                    if character.getX() < slider.position.x {
                        character.turn(left: false)
                    } else {
                        character.turn(left: true)
                    }
                }
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let st = sliderTouch {
            if touches.contains(st) {
                sliderIsTriggered = false
                slider.run(scaleDownAnimation)
            }
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
