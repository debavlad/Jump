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
    var sky, platform, character, line, slider: SKSpriteNode!
    var cam: SKCameraNode!
    
    var platformManager: PlatformManager!
    var bgCloudManager, fgCloudManager: CloudManager!
    var sliderIsTriggered = false
    var jumpAnimation: SKAction!
    var movement: CGFloat!
    
    override func didMove(to view: SKView) {
        self.physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVector(dx: 0, dy: -18)
        
        sky = childNode(withName: "sky") as? SKSpriteNode
        platform = childNode(withName: "platform") as? SKSpriteNode
        character = childNode(withName: "character") as? SKSpriteNode
        line = childNode(withName: "line") as? SKSpriteNode
        slider = childNode(withName: "slider") as? SKSpriteNode
        cam = SKCameraNode()
        
        platformManager = PlatformManager(150, platform.position.y, wOffset: -100, hOffset: 50)
        bgCloudManager = CloudManager(250, frame.minY, wOffset: 0, hOffset: 50)
        fgCloudManager = CloudManager(1200, frame.minY, wOffset: 50, hOffset: 50)
        slider.position.x = character.position.x
        movement = character.position.x
        
        setCamera()
        setPhysicsBodiesOptions()
        setFilteringMode()
        createJumpAnimation()
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if character.physicsBody!.velocity.dy < 0 {
            character.run(jumpAnimation)
            character.physicsBody?.velocity = CGVector()
            character.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 70))
        }
//        let collision: UInt32 = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
//        if collision == characterCategory | platformCategory {
//            //print("Collision between platform and character!")
//        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        camera!.position.y = lerp(start: (camera?.position.y)!, end: character.position.y, percent: 0.065)
        character.position.x = movement
        
        if platformManager.canCreate(playerPosition: character.position) {
            addChild(platformManager.instantiate())
        }
        
        if bgCloudManager.canCreate(playerPosition: character.position) {
            addChild(bgCloudManager.getBackgroundCloud())
        }
        
        if fgCloudManager.canCreate(playerPosition: character.position) {
            addChild(fgCloudManager.getForegroundCloud())
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let touchedNode = atPoint(touch.location(in: self))
        
        if touchedNode == slider {
            sliderIsTriggered = true
            slider.setScale(1.2)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if sliderIsTriggered {
            let touchLocationX = touches.first!.location(in: self).x
            let halfLine = line.size.width / 2
            
            if touchLocationX > -halfLine && touchLocationX < halfLine {
                slider.position.x = touchLocationX
                movement = lerp(start: character.position.x, end: slider.position.x, percent: 0.2)
                if character.position.x < slider.position.x {
                    character.xScale = 2.5
                } else {
                    character.xScale = -2.5
                }
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        sliderIsTriggered = false
        slider.setScale(1)
    }
    
    //
    
    func setCamera() {
        camera = cam
        sky.move(toParent: cam)
        slider.move(toParent: cam)
        line.move(toParent: cam)
        addChild(cam)
    }
    
    func setPhysicsBodiesOptions() {
        character.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 50, height: 20), center: CGPoint(x: -5, y: -50))
        character.physicsBody?.usesPreciseCollisionDetection = true
        character.physicsBody?.collisionBitMask = 0
        character.physicsBody?.categoryBitMask = Categories.character
        character.physicsBody?.contactTestBitMask = Categories.woodenPlatform | Categories.stonePlatform
        
        platform.physicsBody?.categoryBitMask = Categories.woodenPlatform
        platform.physicsBody?.contactTestBitMask = 0
    }
    
    func setFilteringMode() {
        sky.texture?.filteringMode = .nearest
        platform.texture?.filteringMode = .nearest
        character.texture?.filteringMode = .nearest
        line.texture?.filteringMode = .nearest
        slider.texture?.filteringMode = .nearest
    }
    
    func createJumpAnimation() {
        var jumpTextures: [SKTexture] = []
        
        for i in 1...6 {
            jumpTextures.append(SKTexture(imageNamed: "fjump\(i)"))
            jumpTextures[i-1].filteringMode = .nearest
        }
        jumpAnimation = SKAction.animate(with: jumpTextures, timePerFrame: 0.12)
    }
    
    func lerp(start: CGFloat, end: CGFloat, percent: CGFloat) -> CGFloat {
        return start + percent * (end - start)
    }
}
