//
//  Trail.swift
//  Jump
//
//  Created by debavlad on 8/26/19.
//  Copyright © 2019 Vladislav Deba. All rights reserved.
//

import Foundation
import SpriteKit

class Trail {
    private let target: SKSpriteNode
    private var lastParticle: SKSpriteNode!
    private let particleTexture: SKTexture
    private let anim: SKAction
    
    init(_ target: SKSpriteNode) {
        self.target = target
        anim = SKAction.group([SKAction.fadeOut(withDuration: 1),
                                    SKAction.scale(to: 0.7, duration: 1)])
        anim.timingMode = SKActionTimingMode.easeIn
        particleTexture = SKTexture(imageNamed: "particle")
    }
    
    func create(in parent: SKNode, _ scale: CGFloat = 18) {
        let particle = SKSpriteNode(texture: particleTexture)
        particle.position = target.position
        particle.zRotation = CGFloat.random(in: -20...20)
        particle.zPosition = 9
        particle.setScale(scale)
        lastParticle = particle
        
        let remove = SKAction.run { particle.removeFromParent() }
        let seq = SKAction.sequence([anim, remove])
        parent.addChild(particle)
        particle.run(seq)
    }
    
    func distance() -> CGFloat {
        let xDist = target.position.x - lastParticle.position.x
        let yDist = target.position.y - lastParticle.position.y
        let dist = sqrt((xDist * xDist) + (yDist * yDist))
        return dist
    }
}
