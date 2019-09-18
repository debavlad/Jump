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
    private let target: SKSpriteNode!
    private var lastParticle: SKSpriteNode!
    private let anim: SKAction!
    
    init(target: SKSpriteNode) {
        self.target = target
        anim = SKAction.group([SKAction.fadeOut(withDuration: 1),
                                    SKAction.scale(to: 0.5, duration: 1)])
        anim.timingMode = SKActionTimingMode.easeIn
    }
    
    func create(in parent: SKNode, scale: CGFloat = 15) {
        // Creating new particle
        let particle = SKSpriteNode(imageNamed: "particle")
        particle.position = target.position
        particle.zPosition = 9
        particle.setScale(scale)
        lastParticle = particle
        
        // Animate and remove
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
