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
    var jumpTextures: [SKTexture] = []
    var jumpAnimation: SKAction!
    
    var pm: PlatformManager!
    
    var bg = SKSpriteNode()
    var platform1 = SKSpriteNode()
    var platform2 = SKSpriteNode()
    var character = SKSpriteNode()
    
    let characterCategory: UInt32 = 0x1 << 0
    let platformCategory: UInt32 = 0x1 << 1
    
    
    override func didMove(to view: SKView) {
        self.physicsWorld.contactDelegate = self
        
        bg = childNode(withName: "sky") as! SKSpriteNode
        platform1 = childNode(withName: "platform1") as! SKSpriteNode
        character = childNode(withName: "character") as! SKSpriteNode
        
        pm = PlatformManager(step: 1.5, maxY: platform1.position.y)
        
        character.physicsBody?.usesPreciseCollisionDetection = true
        character.physicsBody?.collisionBitMask = 0
        character.physicsBody?.categoryBitMask = characterCategory
        character.physicsBody?.contactTestBitMask = platformCategory
        
        platform1.physicsBody?.categoryBitMask = platformCategory
        platform1.physicsBody?.contactTestBitMask = 0
        
        physicsWorld.gravity = CGVector(dx: 0, dy: -18)
        
        bg.texture?.filteringMode = .nearest
        platform1.texture?.filteringMode = .nearest
        character.texture?.filteringMode = .nearest
        
        for i in 1...6 {
            jumpTextures.append(SKTexture(imageNamed: "fjump\(i)"))
            jumpTextures[i-1].filteringMode = .nearest
        }
        
        jumpAnimation = SKAction.animate(with: jumpTextures, timePerFrame: 0.15)
        
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if character.physicsBody!.velocity.dy < 0 {
            character.run(jumpAnimation)
            character.physicsBody?.velocity = CGVector()
            character.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 1200))
        }
//        let collision: UInt32 = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
//        if collision == characterCategory | platformCategory {
//
//            //print("Collision between platform and character!")
//        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        if pm.canCreate(characterPosition: character.position) {
            let platform = pm.instantiate()
            addChild(platform)
        }
    }
}
