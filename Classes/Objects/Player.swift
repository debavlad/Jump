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
    private var hp: Int = 100
    private(set) var alive = true
    
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
    
    private(set) var jumpAnim, fallAnim, landAnim, sitAnim: SKAction!
    var currentAnim: SKAction!
    
    init(_ node: SKNode) {
        self.node = node as? SKSpriteNode
        
        green = SKTexture(imageNamed: "hp-green")
        yellow = SKTexture(imageNamed: "hp-yellow")
        red = SKTexture(imageNamed: "hp-red")
        
        hpBorder = node.children.first! as? SKSpriteNode
        hpStripe = hpBorder.children.first! as? SKSpriteNode
        maxStripeWidth = hpStripe.size.width
        
        setPhysics()
        setAnimations()
        turn(left: true)
        node.run(SKAction.repeatForever(sitAnim))
    }
    
    func animate(_ anim: SKAction) {
        node.run(anim)
        currentAnim = anim
    }
    
    func fallingDown() -> Bool {
        return node.physicsBody!.velocity.dy < 0
    }
    
    private func setHp(value: Int) {
        if value <= 0 {
            hp = 0
            alive = false
            hpStripe.size.width = 0
        } else if value >= 100 {
            hp = 100
            hpStripe.size.width = maxStripeWidth
        } else {
            hp = value
            hpStripe.size.width = maxStripeWidth / 100 * CGFloat(value)
            setStripeColor(hp: value)
        }
    }
    
    func harm(by amount: Int) {
        setHp(value: hp - amount)
    }
    
    func heal(by amount: Int) {
        setHp(value: hp + amount)
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
        node.physicsBody?.categoryBitMask = Categories.player
        node.physicsBody?.contactTestBitMask = Categories.coin | Categories.platform
        node.physicsBody?.allowsRotation = false
        node.physicsBody?.friction = 0
        node.physicsBody?.restitution = 0
        node.physicsBody?.linearDamping = 0
        node.physicsBody?.angularDamping = 0
    }
    
    private func setAnimations() {
        var jump: [SKTexture] = []
        for i in 0...3 {
            jump.append(SKTexture(imageNamed: "jump\(i)").pixelated())
        }
        jumpAnim = SKAction.animate(with: jump, timePerFrame: 0.125)
        
        var fall: [SKTexture] = []
        for i in 4...5 {
            fall.append(SKTexture(imageNamed: "jump\(i)").pixelated())
        }
        fallAnim = SKAction.animate(with: fall, timePerFrame: 0.125)
        
        var land: [SKTexture] = []
        for i in 6...8 {
            land.append(SKTexture(imageNamed: "jump\(i)").pixelated())
        }
        landAnim = SKAction.animate(with: land, timePerFrame: 0.06)
        
        var sit: [SKTexture] = []
        for i in 0...7 {
            sit.append(SKTexture(imageNamed: "sit\(i)").pixelated())
        }
        sitAnim = SKAction.animate(with: sit, timePerFrame: 0.15)
    }
}
