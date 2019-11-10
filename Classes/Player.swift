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
    let sprite: SKSpriteNode
    private var health, maxHp: Int!
    private(set) var isAlive = true
    private(set) var score = 0
    private let green, yellow, red: SKTexture!
    private let hpBorder, hpLine: SKSpriteNode!
    private let maxLineWidth: CGFloat
    
    private(set) var currentAnim, jumpAnim, fallAnim, landAnim, sitAnim: SKAction!
    
    
    func getAlive() {
        isAlive = true
//        health = maxHp
        editHp(200)
    }
    
    init(_ node: SKNode) {
        self.sprite = node as! SKSpriteNode
        green = SKTexture(imageNamed: "hp-green")
        yellow = SKTexture(imageNamed: "hp-yellow")
        red = SKTexture(imageNamed: "hp-red")
        hpBorder = node.children.first! as? SKSpriteNode
        hpLine = hpBorder.children.first! as? SKSpriteNode
        maxLineWidth = hpLine.size.width
        
        setNodes()
    }
    
    func push(power: Int) {
        runAnimation(jumpAnim)
        sprite.physicsBody!.velocity = CGVector()
        sprite.physicsBody!.applyImpulse(CGVector(dx: 0, dy: power))
    }
    
    func turn(left: Bool) {
        sprite.xScale = left ? -1 : 1
        hpBorder.xScale = sprite.xScale
    }
    
    func setScore(_ val: Int) {
        score = val
    }
    
    func editHp(_ val: Int) {
        let amount = health + val
        
        if amount <= 0 {
            health = 0
            isAlive = false
            hpLine.size.width = 0
        } else if amount >= maxHp {
            health = maxHp
            hpLine.size.width = maxLineWidth
        } else {
            health = amount
            hpLine.size.width = maxLineWidth/CGFloat(maxHp) * CGFloat(amount)
            // Setting line color
            if amount <= 25 {
                hpLine.texture = red
            } else if amount <= 50 {
                hpLine.texture = yellow
            } else if amount <= 100 {
                hpLine.texture = green
            }
        }
    }
    
    func isFalling() -> Bool {
        return sprite.physicsBody!.velocity.dy < 0
    }
    
    func runAnimation(_ anim: SKAction) {
        sprite.run(anim)
        currentAnim = anim
    }
    
    private func setNodes() {
        // Physics
        sprite.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 50, height: 20), center: CGPoint(x: -5, y: -50))
        sprite.physicsBody?.collisionBitMask = Categories.ground
        sprite.physicsBody?.categoryBitMask = Categories.player
        sprite.physicsBody?.contactTestBitMask = Categories.coin | Categories.food | Categories.platform
        sprite.physicsBody?.allowsRotation = false
        sprite.physicsBody?.friction = 0
        sprite.physicsBody?.restitution = GameScene.restarted ? 0.4 : 0
        sprite.physicsBody?.linearDamping = 0
        sprite.physicsBody?.angularDamping = 0
        
        // Animations
        let skinName = "\(ShopScene.skins[GameScene.skinIndex].name)"
        maxHp = skinName == "zombie" ? 150 : 100
        health = maxHp
        
        var textures = [SKTexture]()
        for i in 0...3 {
            textures.append(SKTexture(imageNamed: "\(skinName)-jump\(i)").px())
        }
        jumpAnim = SKAction.animate(with: textures, timePerFrame: 0.11)
        textures.removeAll(keepingCapacity: true)
        
        for i in 4...5 {
            textures.append(SKTexture(imageNamed: "\(skinName)-jump\(i)").px())
        }
        fallAnim = SKAction.animate(with: textures, timePerFrame: 0.11)
        textures.removeAll(keepingCapacity: true)
        
        for i in 6...8 {
            textures.append(SKTexture(imageNamed: "\(skinName)-jump\(i)").px())
        }
        landAnim = SKAction.animate(with: textures, timePerFrame: 0.06)
        textures.removeAll(keepingCapacity: true)
        
        for i in 0...7 {
            textures.append(SKTexture(imageNamed: "\(skinName)-sit\(i)").px())
        }
        sitAnim = SKAction.animate(with: textures, timePerFrame: 0.15)
        textures.removeAll()
        
        sprite.run(SKAction.repeatForever(sitAnim))
    }
}
