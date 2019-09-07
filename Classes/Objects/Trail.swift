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
    private var lastParticle: SKSpriteNode!
    private let player: SKSpriteNode!
    private let anim: SKAction!
    
    init(player: SKSpriteNode) {
        self.player = player
        
        anim = SKAction.group([SKAction.fadeOut(withDuration: 1),
                                    SKAction.scale(to: 0.5, duration: 1)])
        anim.timingMode = SKActionTimingMode.easeIn
    }
    
    func create(in parent: SKNode, scale: CGFloat = 15) {
        // Creating new particle
        let point = SKSpriteNode(imageNamed: "particle")
        point.position = player.position
        point.zPosition = 9
        point.setScale(scale)
        lastParticle = point
        
        // Animate and remove
        let remove = SKAction.run { point.removeFromParent() }
        let seq = SKAction.sequence([anim, remove])
        parent.addChild(point)
        point.run(seq)
    }
    
    func distance() -> CGFloat {
        let xDist = player.position.x - lastParticle.position.x
        let yDist = player.position.y - lastParticle.position.y
        let dist = sqrt((xDist * xDist) + (yDist * yDist))
        return dist
    }
}
