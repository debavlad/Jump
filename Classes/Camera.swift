//
//  Camera.swift
//  Jump
//
//  Created by Vladislav Deba on 8/15/19.
//  Copyright © 2019 Vladislav Deba. All rights reserved.
//

import Foundation
import SpriteKit

class Camera {
    let node: SKCameraNode
    var easing: CGFloat
    
    init(_ scene: SKScene) {
        node = SKCameraNode()
        node.name = "Cam"
        scene.camera = node
        scene.addChild(node)
        easing = 0.072
    }
    
    func shake(_ amplitude: CGFloat, _ amount: Int, _ step: CGFloat, _ duration: CGFloat) {
        var amp = amplitude
        var actions: [SKAction] = []
        for _ in 1...amount {
            var tmp = Bool.random()
            let x = tmp ? amp : -amp
            tmp = Bool.random()
            let y = tmp ? amp : -amp
            
            let action = SKAction.moveBy(x: x, y: y, duration: TimeInterval(duration))
            action.timingMode = SKActionTimingMode.easeOut
            actions.append(action)
            actions.append(action.reversed())
            
            amp -= step
        }
        
        let seq = SKAction.sequence(actions)
        node.run(seq)
    }
    
    func earthquake() {
        var amp = 20
        var actions: [SKAction] = []
        for _ in 1...2 {
            let tmp = Bool.random()
            let i = CGFloat.random(in: 15...20)
            let x: CGFloat = tmp ? i : -i
            let j = CGFloat.random(in: 15...20)
            let y: CGFloat = -j
            
            let action = SKAction.moveBy(x: x, y: y, duration: 0.075)
            action.timingMode = .easeOut
            actions.append(action)
            actions.append(action.reversed())
            
            amp -= 6
        }
        
        let seq = SKAction.sequence(actions)
        node.run(seq)
    }
}
