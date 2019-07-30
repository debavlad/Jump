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
    var sky = SKSpriteNode()
    var platform = SKSpriteNode()
    var character = SKSpriteNode()
    
    var jumpAnimation: SKAction!
    var pm: PlatformManager!
    
    override func didMove(to view: SKView) {
        self.physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVector(dx: 0, dy: -18)
        
        sky = childNode(withName: "sky") as! SKSpriteNode
        platform = childNode(withName: "platform") as! SKSpriteNode
        character = childNode(withName: "character") as! SKSpriteNode
        pm = PlatformManager(step: 1.5, maxY: platform.position.y)
        
        setPhysicsBodiesOptions()
        setFilteringMode()
        createJumpAnimation()
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if character.physicsBody!.velocity.dy < 0 {
            character.run(jumpAnimation)
            character.physicsBody?.velocity = CGVector()
            character.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 1200))
        }
        
//        let collision: UInt32 = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
//        if collision == characterCategory | platformCategory {
//            //print("Collision between platform and character!")
//        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        if pm.canCreate(characterPosition: character.position) {
            let platform = pm.instantiate()
            addChild(platform)
        }
    }
    
    // 
    
    func setPhysicsBodiesOptions() {
        character.physicsBody?.usesPreciseCollisionDetection = true
        character.physicsBody?.collisionBitMask = 0
        character.physicsBody?.categoryBitMask = Categories.characterCategory
        character.physicsBody?.contactTestBitMask = Categories.platformCategory
        
        platform.physicsBody?.categoryBitMask = Categories.platformCategory
        platform.physicsBody?.contactTestBitMask = 0
    }
    
    func setFilteringMode() {
        sky.texture?.filteringMode = .nearest
        platform.texture?.filteringMode = .nearest
        character.texture?.filteringMode = .nearest
    }
    
    func createJumpAnimation() {
        var jumpTextures: [SKTexture] = []
        
        for i in 1...6 {
            jumpTextures.append(SKTexture(imageNamed: "fjump\(i)"))
            jumpTextures[i-1].filteringMode = .nearest
        }
        jumpAnimation = SKAction.animate(with: jumpTextures, timePerFrame: 0.15)
    }
}
