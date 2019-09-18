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
    let node: SKCameraNode!
    
    var x: CGFloat {
        set { node.position.x = newValue }
        get { return node.position.x }
    }
    var y: CGFloat {
        set { node.position.y = newValue }
        get { return node.position.y }
    }
    var minY: CGFloat {
        get { return node.frame.minY }
    }
    var maxY: CGFloat {
        get { return node.frame.maxY }
    }
    var easing: CGFloat!
    
    init(scene: SKScene) {
        node = SKCameraNode()
        node.name = "Cam"
        scene.camera = node
        scene.addChild(node)
        easing = 0.07
    }
    
    // def (1.5, 5, 0, 2)   
    // for item (10, 2, 4, 0.08)
    // for start (40, 6, 6, 0.04)
    func shake(amplitude: CGFloat, amount: Int, step: CGFloat, duration: CGFloat) {
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
}
