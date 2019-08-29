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
    var last: SKSpriteNode!
    let player: SKSpriteNode!
    
    init(player: SKSpriteNode) {
        self.player = player
    }
    
    func create(in parent: SKNode, scale: CGFloat = 15) {
        let trail = SKSpriteNode(imageNamed: "particle")
        trail.position = player.position
        trail.zPosition = 9
        trail.setScale(scale)
        trail.color = UIColor.white
        trail.colorBlendFactor = 1
        last = trail
        
        let fadeOut = SKAction.fadeOut(withDuration: 1)
        let scaleDown = SKAction.scale(to: 0.5, duration: 1)
        let group = SKAction.group([fadeOut, scaleDown])
        group.timingMode = SKActionTimingMode.easeIn
        
        let remove = SKAction.run {
            trail.removeFromParent()
        }
        let sequence = SKAction.sequence([group, remove])
        
        parent.addChild(trail)
        trail.run(sequence)
    }
    
    func distance() -> CGFloat {
        let xDist = player.position.x - last.position.x
        let yDist = player.position.y - last.position.y
        let dist = sqrt((xDist * xDist) + (yDist * yDist))
        return dist
    }
}
