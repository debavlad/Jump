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
        set { sprite.position.x = newValue }
        get { return sprite.position.x }
    }
    var y: CGFloat {
        get { return sprite.position.y }
    }
    let sprite: SKSpriteNode
    private var health: Int = 100
    private(set) var isAlive = true
    private(set) var score = 0
    
    private let green, yellow, red: SKTexture!
    private let hpBorder, hpLine: SKSpriteNode!
    private let maxLineWidth: CGFloat
    
    private(set) var currentAnim, jumpAnim, fallAnim, landAnim, sitAnim: SKAction!
    
    
    init(_ node: SKNode) {
        self.sprite = node as! SKSpriteNode
        
        green = SKTexture(imageNamed: "hp-green")
        yellow = SKTexture(imageNamed: "hp-yellow")
        red = SKTexture(imageNamed: "hp-red")
        hpBorder = node.children.first! as? SKSpriteNode
        hpLine = hpBorder.children.first! as? SKSpriteNode
        maxLineWidth = hpLine.size.width
        
        setPhysics()
        setAnimations()
        node.run(SKAction.repeatForever(sitAnim))
    }
    
    func run(animation: SKAction) {
        sprite.run(animation)
        currentAnim = animation
    }
    
    func set(score: Int) {
        self.score = score
    }
    
    func isFalling() -> Bool {
        return sprite.physicsBody!.velocity.dy < 0
    }
    
    func harm(by amount: Int) {
        set(hp: health - amount)
    }
    
    func heal(by amount: Int) {
        set(hp: health + amount)
    }
    
    func push(power: Int) {
        sprite.run(jumpAnim)
        sprite.physicsBody!.velocity = CGVector()
        sprite.physicsBody!.applyImpulse(CGVector(dx: 0, dy: power))
    }
    
    func turn(left: Bool) {
        if left {
            sprite.xScale = -1
            hpBorder.xScale = -1
        } else {
            sprite.xScale = 1
            hpBorder.xScale = 1
        }
    }
    
    
    private func set(hp: Int) {
        if hp <= 0 {
            self.health = 0
            isAlive = false
            hpLine.size.width = 0
        } else if hp >= 100 {
            self.health = 100
            hpLine.size.width = maxLineWidth
        } else {
            self.health = hp
            hpLine.size.width = maxLineWidth / 100 * CGFloat(hp)
            setLineColor()
        }
    }
    
    private func setLineColor() {
        if health <= 25 {
            hpLine.texture = red
        } else if health <= 50 {
            hpLine.texture = yellow
        } else if health <= 100 {
            hpLine.texture = green
        }
    }
    
    private func setPhysics() {
        sprite.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 50, height: 20), center: CGPoint(x: -5, y: -50))
        sprite.physicsBody?.collisionBitMask = Categories.ground
        sprite.physicsBody?.categoryBitMask = Categories.player
        sprite.physicsBody?.contactTestBitMask = Categories.coin | Categories.food | Categories.platform
        sprite.physicsBody?.allowsRotation = false
        sprite.physicsBody?.friction = 0
        if GameScene.restarted {
            sprite.physicsBody?.restitution = 0.4
        } else {
            sprite.physicsBody?.restitution = 0
        }
        sprite.physicsBody?.linearDamping = 0
        sprite.physicsBody?.angularDamping = 0
    }
    
    private func setAnimations() {
        var jumpTextures = [SKTexture](),
            fallTextures = [SKTexture](),
            landTextures = [SKTexture](),
            sitTextures = [SKTexture]()
        
        for i in 0...3 {
            jumpTextures.append(SKTexture(imageNamed: "\(GameScene.skinName)-jump\(i)").px())
        }
        
        for i in 4...5 {
            fallTextures.append(SKTexture(imageNamed: "\(GameScene.skinName)-jump\(i)").px())
        }
        
        for i in 6...8 {
            landTextures.append(SKTexture(imageNamed: "\(GameScene.skinName)-jump\(i)").px())
        }
        
        for i in 0...7 {
            sitTextures.append(SKTexture(imageNamed: "\(GameScene.skinName)-sit\(i)").px())
        }
        
        jumpAnim = SKAction.animate(with: jumpTextures, timePerFrame: 0.11)
        fallAnim = SKAction.animate(with: fallTextures, timePerFrame: 0.11)
        landAnim = SKAction.animate(with: landTextures, timePerFrame: 0.06)
        sitAnim = SKAction.animate(with: sitTextures, timePerFrame: 0.15)
    }
}
