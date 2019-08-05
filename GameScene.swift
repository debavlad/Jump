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
    var sky, platform, character, line, slider, button, black: SKSpriteNode!
    var jumpUpAnimation, jumpSideAnimation, scaleUpAnimation, scaleDownAnimation: SKAction!
    var pauseTexture, playTexture: SKTexture!
    var sliderTouch: UITouch!
    
    var movement: CGFloat!
    var manager: Manager!
    var sliderIsTriggered = false
    
    override func didMove(to view: SKView) {
        setNodes()
        setPhysics()
        setAnimations()
        setManagers()
        setCamera()
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let collision: UInt32 = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        if collision == Collisions.characterAndCoin {
            let coin = contact.bodyA.node?.name == "coin" ? contact.bodyA.node : contact.bodyB.node
            coin?.userData?.setValue(true, forKey: "isPickedUp")
        }
        
        if character.physicsBody!.velocity.dy < 0 {
            if collision == Collisions.characterAndWood {
                pushCharacter(power: 70)
            } else if collision == Collisions.characterAndStone {
                pushCharacter(power: 80)
            }
            
            if collision == Collisions.characterAndWood || collision == Collisions.characterAndStone {
                let platform = (contact.bodyA.node?.name == "platform" ? contact.bodyA.node : contact.bodyB.node)!
                if platform.children.count > 0 {
                    guard let coin = platform.children.first(where: { (n) -> Bool in
                        return n.name!.contains("coin")
                    }) else { return }
                    
                    if coin.userData?.value(forKey: "isPickedUp") as! Bool == true {
                        let type: CoinType!
                        if coin.name!.contains("dirt") {
                            type = CoinType.dirt
                        } else if coin.name!.contains("bronze") {
                            type = CoinType.bronze
                        } else {
                            type = CoinType.golden
                        }
                        let particles = getParticles(type: type, targetNode: platform)
                        platform.addChild(particles)
                        coin.removeFromParent()
                    }
                }
            }
        }
    }

    override func update(_ currentTime: TimeInterval) {
        camera!.position.y = lerp(start: (camera?.position.y)!, end: character.position.y, percent: 0.065)
        movement = lerp(start: character.position.x, end: slider.position.x, percent: 0.2)
        character.position.x = movement
        
        if manager.bgClouds.canCreate(playerY: character.position.y) {
            let cloud = manager.bgClouds.instantiate()
            worldNode.addChild(cloud)
        }
        
        if manager.fgClouds.canCreate(playerY: character.position.y) {
            let cloud = manager.fgClouds.instantiate()
            worldNode.addChild(cloud)
        }
        
        if manager.platforms.canCreate(playerY: character.position.y) {
            let platform = manager.platforms.instantiate()
            worldNode.addChild(platform)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let node = atPoint(touch.location(in: self))
        
        if node == slider {
            sliderIsTriggered = true
            sliderTouch = touch
            slider.run(scaleUpAnimation)
        } else if node == button {
            sliderIsTriggered = false
            if button.texture == playTexture {
                button.texture = pauseTexture
                worldNode.isPaused = false
                physicsWorld.speed = 1
                line.isHidden = false
                slider.isHidden = false
                black.alpha = 0
            } else {
                button.texture = playTexture
                worldNode.isPaused = true
                physicsWorld.speed = 0
                line.isHidden = true
                slider.isHidden = true
                black.alpha = 0.3
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if sliderIsTriggered {
            
            if let st = sliderTouch {
                let touchLocationX = st.location(in: self).x
                let halfLine = line.size.width / 2
                
                if touchLocationX > -halfLine && touchLocationX < halfLine {
                    slider.position.x = touchLocationX
                    if character.position.x < slider.position.x {
                        character.xScale = 2.5
                    } else {
                        character.xScale = -2.5
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
    
    //
    
    func lerp(start: CGFloat, end: CGFloat, percent: CGFloat) -> CGFloat {
        return start + percent * (end - start)
    }
    
    fileprivate func setNodes() {
        sky = childNode(withName: "sky")?.pixelate()
        platform = childNode(withName: "platform")?.pixelate()
        character = childNode(withName: "character")?.pixelate()
        line = childNode(withName: "line")?.pixelate()
        slider = childNode(withName: "slider")?.pixelate()
        button = childNode(withName: "pause")?.pixelate()
        black = childNode(withName: "black")?.pixelate()
        playTexture = SKTexture(imageNamed: "continue").pixelate()
        pauseTexture = SKTexture(imageNamed: "pause").pixelate()
        
        
        slider.position.x = character.position.x
        movement = character.position.x
        
        worldNode = SKNode()
        character.move(toParent: worldNode)
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
        var jumpUpTextures: [SKTexture] = []
        for i in 0...5 {
            jumpUpTextures.append(SKTexture(imageNamed: "fjump\(i)").pixelate())
        }
        jumpUpAnimation = SKAction.animate(with: jumpUpTextures, timePerFrame: 0.12)
        
        var jumpSideTextures: [SKTexture] = []
        for i in 0...8 {
            jumpSideTextures.append(SKTexture(imageNamed: "fjside\(i)").pixelate())
        }
        jumpSideAnimation = SKAction.animate(with: jumpSideTextures, timePerFrame: 0.11)
        
        scaleUpAnimation = SKAction.scale(to: 1.3, duration: 0.1)
        scaleDownAnimation = SKAction.scale(to: 1, duration: 0.1)
    }
    
    fileprivate func setManagers() {
        // TO-DO: change hardcoded frameMinY value
        manager = Manager(startY: platform.position.y, frameMinY: -900)
    }
    
    fileprivate func setPhysics() {
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVector(dx: 0, dy: -20)
        
        character.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 50, height: 20), center: CGPoint(x: -5, y: -50))
        character.physicsBody?.usesPreciseCollisionDetection = true
        character.physicsBody?.collisionBitMask = 0
        character.physicsBody?.allowsRotation = false
        character.physicsBody?.categoryBitMask = Categories.character
        character.physicsBody?.contactTestBitMask = Categories.coin | Categories.woodenPlatform | Categories.stonePlatform
        character.physicsBody?.friction = 0
        character.physicsBody?.restitution = 0
        character.physicsBody?.linearDamping = 0
        character.physicsBody?.angularDamping = 0
        
        platform.physicsBody?.categoryBitMask = Categories.woodenPlatform
        platform.physicsBody?.contactTestBitMask = 0
    }
    
    //
    
    fileprivate func pushCharacter(power: Int) {
        character.run(jumpSideAnimation)
        character.physicsBody?.velocity = CGVector()
        character.physicsBody?.applyImpulse(CGVector(dx: 0, dy: power))
    }
    
    fileprivate func getParticles(type: CoinType, targetNode: SKNode) -> SKEmitterNode {
        let particles: SKEmitterNode!
        
        switch (type) {
        case .dirt:
            particles = SKEmitterNode(fileNamed: "DirtParticles")!
        case .bronze:
            particles = SKEmitterNode(fileNamed: "BronzeParticles")!
        case .golden:
            particles = SKEmitterNode(fileNamed: "GoldenParticles")!
        }
        
        particles.name = String()
        particles.targetNode = targetNode
        particles.position = CGPoint(x: 0, y: 70)
        
        return particles
    }
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
