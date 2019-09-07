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
    let node: SKSpriteNode!
    
    private var hp: Int = 100
    private(set) var alive = true
    private(set) var score = 0
    private let green, yellow, red: SKTexture!
    private let hpBorder, hpStripe: SKSpriteNode!
    private let maxHpStripeWidth: CGFloat
    
    private(set) var currAnim, jumpAnim, fallAnim, landAnim, sitAnim: SKAction!
    
    
    init(_ node: SKNode) {
        self.node = node as? SKSpriteNode
        
        green = SKTexture(imageNamed: "hp-green")
        yellow = SKTexture(imageNamed: "hp-yellow")
        red = SKTexture(imageNamed: "hp-red")
        hpBorder = node.children.first! as? SKSpriteNode
        hpStripe = hpBorder.children.first! as? SKSpriteNode
        maxHpStripeWidth = hpStripe.size.width
        
        setPhysics()
        setAnimations()
        node.run(SKAction.repeatForever(sitAnim))
    }
    
    func run(animation: SKAction) {
        node.run(animation)
        currAnim = animation
    }
    
    func set(score: Int) {
        self.score = score
    }
    
    func falling() -> Bool {
        return node.physicsBody!.velocity.dy < 0
    }
    
    func harm(by amount: Int) {
        set(hp: hp - amount)
    }
    
    func heal(by amount: Int) {
        set(hp: hp + amount)
    }
    
    func push(power: Int) {
        node.run(jumpAnim)
        node.physicsBody!.velocity = CGVector()
        node.physicsBody!.applyImpulse(CGVector(dx: 0, dy: power))
    }
    
    func turn(left: Bool) {
        if left {
            node.xScale = -1
            hpBorder.xScale = -1
        } else {
            node.xScale = 1
            hpBorder.xScale = 1
        }
    }
    
    
    private func set(hp: Int) {
        if hp <= 0 {
            self.hp = 0
            alive = false
            hpStripe.size.width = 0
        } else if hp >= 100 {
            self.hp = 100
            hpStripe.size.width = maxHpStripeWidth
        } else {
            self.hp = hp
            hpStripe.size.width = maxHpStripeWidth / 100 * CGFloat(hp)
            setStripeColor()
        }
    }
    
    private func setStripeColor() {
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
        node.physicsBody?.collisionBitMask = Categories.ground
        node.physicsBody?.categoryBitMask = Categories.player
        node.physicsBody?.contactTestBitMask = Categories.coin | Categories.food | Categories.platform
        node.physicsBody?.allowsRotation = false
        node.physicsBody?.friction = 0
        if GameScene.restarted {
            node.physicsBody?.restitution = 0.4
        } else {
            node.physicsBody?.restitution = 0
        }
        node.physicsBody?.linearDamping = 0
        node.physicsBody?.angularDamping = 0
    }
    
    private func setAnimations() {
        var jumpTextures = [SKTexture](),
            fallTextures = [SKTexture](),
            landTextures = [SKTexture](),
            sitTextures = [SKTexture]()
        
        for i in 0...3 {
            jumpTextures.append(SKTexture(imageNamed: "\(GameScene.skinName)-jump\(i)").pixelated())
        }
        
        for i in 4...5 {
            fallTextures.append(SKTexture(imageNamed: "\(GameScene.skinName)-jump\(i)").pixelated())
        }
        
        for i in 6...8 {
            landTextures.append(SKTexture(imageNamed: "\(GameScene.skinName)-jump\(i)").pixelated())
        }
        
        for i in 0...7 {
            sitTextures.append(SKTexture(imageNamed: "\(GameScene.skinName)-sit\(i)").pixelated())
        }
        
        jumpAnim = SKAction.animate(with: jumpTextures, timePerFrame: 0.11)
        fallAnim = SKAction.animate(with: fallTextures, timePerFrame: 0.11)
        landAnim = SKAction.animate(with: landTextures, timePerFrame: 0.06)
        sitAnim = SKAction.animate(with: sitTextures, timePerFrame: 0.15)
    }
}
