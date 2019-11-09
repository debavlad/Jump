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
            let x = Bool.random() ? amp : -amp
            let y = Bool.random() ? amp : -amp
            amp -= step
            
            let a = SKAction.moveBy(x: x, y: y, duration: TimeInterval(duration))
            a.timingMode = SKActionTimingMode.easeOut
            actions.append(a)
            actions.append(a.reversed())
        }
        
        let seq = SKAction.sequence(actions)
        node.run(seq)
    }
    
    func earthquake() {
        var actions: [SKAction] = []
        for _ in 1...2 {
            var x = CGFloat.random(in: 15...20)
            x *= Bool.random() ? 1 : -1
            let y = -CGFloat.random(in: 15...20)
            
            let a = SKAction.moveBy(x: x, y: y, duration: 0.075)
            a.timingMode = .easeOut
            actions.append(a)
            actions.append(a.reversed())
        }
        
        let seq = SKAction.sequence(actions)
        node.run(seq)
    }
}
