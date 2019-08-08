//
//  Character.swift
//  Jump
//
//  Created by Vladislav Deba on 8/8/19.
//  Copyright © 2019 Vladislav Deba. All rights reserved.
//

import Foundation
import SpriteKit

class Character {
    private var node: SKSpriteNode!
    private var hp: Int
    
    private var hpBorder, hpStripe: SKSpriteNode!
    private var green, yellow, red: SKTexture!
    private var maxStripeWidth: CGFloat
    
    private var jumpAnimation, fadeOut: SKAction!
    
    
    init(_ node: SKNode) {
        self.node = node as? SKSpriteNode
    
        hp = 100
        hpBorder = node.childNode(withName: "hp-border") as? SKSpriteNode
        hpStripe = hpBorder.childNode(withName: "hp-stripe") as? SKSpriteNode
        maxStripeWidth = hpStripe.size.width
        green = SKTexture(imageNamed: "hp-green")
        yellow = SKTexture(imageNamed: "hp-yellow")
        red = SKTexture(imageNamed: "hp-red")
        
        setPhysics()
        setAnimations()
    }
    
    func push(power: Int) {
        node.run(jumpAnimation)
        node.physicsBody!.velocity = CGVector()
        node.physicsBody!.applyImpulse(CGVector(dx: 0, dy: power))
    }
    
    func turn(left: Bool) {
        if left {
            node.xScale = -2.5
            hpBorder.xScale = -0.4
        } else {
            node.xScale = 2.5
            hpBorder.xScale = 0.4
        }
    }
    
    func isFallingDown() -> Bool {
        return node.physicsBody!.velocity.dy < 0
//        character.physicsBody!.velocity.dy < 0
    }
    
    func isDead() -> Bool {
        return hp <= 0
    }
    
    func set(parent: SKNode) {
        node.move(toParent: parent)
    }
    
    func getX() -> CGFloat {
        return node.position.x
    }
    
    func getY() -> CGFloat {
        return node.position.y
    }
    
    func set(x: CGFloat) {
        node.position.x = x
    }
    
    func decreaseHp(by amount: Int) {
        set(hp: hp - amount)
    }
    
    func increaseHp(by amount: Int) {
        set(hp: hp + amount)
    }
    
    private func set(hp: Int) {
        if hp <= 0 {
            // is dead
            self.hp = 0
            hpStripe.size.width = 0
            node.zPosition = -1
            hpBorder.run(fadeOut)
        } else {
            // is alive
            if hp > 0 && hp <= 25 {
                hpStripe.texture = red
            } else if hp > 25 && hp <= 50 {
                hpStripe.texture = yellow
            } else if hp > 50 && hp <= 100 {
                hpStripe.texture = green
            }
            
            self.hp = hp
            hpStripe.size.width = maxStripeWidth / 100 * CGFloat(hp)
        }
    }
    
    private func setPhysics() {
        node.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 50, height: 20), center: CGPoint(x: -5, y: -50))
        node.physicsBody?.usesPreciseCollisionDetection = true
        node.physicsBody?.collisionBitMask = 0
        node.physicsBody?.allowsRotation = false
        node.physicsBody?.categoryBitMask = Categories.character
        node.physicsBody?.contactTestBitMask = Categories.coin | Categories.woodenPlatform | Categories.stonePlatform
        node.physicsBody?.friction = 0
        node.physicsBody?.restitution = 0
        node.physicsBody?.linearDamping = 0
        node.physicsBody?.angularDamping = 0
    }
    
    private func setAnimations() {
        var jumpTextures: [SKTexture] = []
        for i in 0...8 {
            jumpTextures.append(SKTexture(imageNamed: "fjside\(i)").pixelate())
        }
        jumpAnimation = SKAction.animate(with: jumpTextures, timePerFrame: 0.11)
        
        fadeOut = SKAction.fadeAlpha(to: 0, duration: 0.7)
    }
}
