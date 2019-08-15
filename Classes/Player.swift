//
//  Player.swift
//  Jump
//
//  Created by Vladislav Deba on 8/15/19.
//  Copyright © 2019 Vladislav Deba. All rights reserved.
//

import Foundation
import SpriteKit

class Player {
    let node: SKSpriteNode!
    private var hp: Int = 100 {
        willSet {
            if newValue <= 0 {
                self.hp = 0
                alive = false
                hpStripe.size.width = 0
                node.zPosition = -1
            } else if newValue > 100 {
                self.hp = 100
                hpStripe.size.width = maxStripeWidth
            } else {
                self.hp = newValue
                hpStripe.size.width = maxStripeWidth / 100 * CGFloat(newValue)
                setStripeColor(hp: newValue)
            }
        }
    }
    var alive = true
    
    var x: CGFloat {
        set {
            node.position.x = newValue
        }
        get {
            return node.position.x
        }
    }
    var y: CGFloat {
        get {
            return node.position.y
        }
    }
    
    private let green, yellow, red: SKTexture!
    private let hpBorder, hpStripe: SKSpriteNode!
    private let maxStripeWidth: CGFloat
    
    private var jumpAnim, sitAnim: SKAction!
    
    init(_ node: SKNode) {
        self.node = node as? SKSpriteNode
        
        green = SKTexture(imageNamed: "hp-green")
        yellow = SKTexture(imageNamed: "hp-yellow")
        red = SKTexture(imageNamed: "hp-red")
        
        hpBorder = node.childNode(withName: "hp-border") as? SKSpriteNode
        hpStripe = hpBorder.childNode(withName: "hp-stripe") as? SKSpriteNode
        maxStripeWidth = hpStripe.size.width
        
        setPhysics()
        setAnimations()
        turn(left: true)
        node.run(SKAction.repeatForever(sitAnim))
    }
    
    
    func fallingDown() -> Bool {
        return node.physicsBody!.velocity.dy < 0
    }
    
    func harm(by amount: Int) {
        hp -= amount
    }
    
    func heal(by amount: Int) {
        hp += amount
    }
    
    func push(power: Int) {
        node.run(jumpAnim)
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
    
    func setParent(_ parent: SKNode) {
        node.move(toParent: parent)
    }
    
    private func setStripeColor(hp: Int) {
        if hp > 0 && hp <= 25 {
            hpStripe.texture = red
        } else if hp > 25 && hp <= 50 {
            hpStripe.texture = yellow
        } else if hp > 50 && hp <= 100 {
            hpStripe.texture = green
        }
    }
    
    private func setPhysics() {
        node.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 50, height: 20), center: CGPoint(x: -5, y: -50))
//        node.physicsBody?.usesPreciseCollisionDetection = true
        node.physicsBody?.collisionBitMask = Categories.ground
        node.physicsBody?.categoryBitMask = Categories.character
        node.physicsBody?.contactTestBitMask = Categories.coin | Categories.platform
        node.physicsBody?.allowsRotation = false
        node.physicsBody?.friction = 0
        node.physicsBody?.restitution = 0
        node.physicsBody?.linearDamping = 0
        node.physicsBody?.angularDamping = 0
    }
    
    private func setAnimations() {
        var jump: [SKTexture] = []
        for i in 0...8 {
            jump.append(SKTexture(imageNamed: "jump\(i)").pixelate())
        }
        jumpAnim = SKAction.animate(with: jump, timePerFrame: 0.11
        )
        
        var sit: [SKTexture] = []
        for i in 0...7 {
            sit.append(SKTexture(imageNamed: "sit\(i)").pixelate())
        }
        sitAnim = SKAction.animate(with: sit, timePerFrame: 0.15)
    }
}
