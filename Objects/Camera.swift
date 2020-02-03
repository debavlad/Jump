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
		easing = 0.09
	}
	
	func punch(_ amp: CGFloat, _ dur: CGFloat) {
		let x = Bool.random() ? amp : -amp
		let action = SKAction.moveBy(x: x, y: -amp, duration: TimeInterval(dur))
		action.timingMode = .easeOut
		let reversed = action.reversed()
		reversed.duration *= 1.5
		reversed.timingMode = .linear
		node.run(SKAction.sequence([action, reversed]))
	}
	
	func shake(_ amp: CGFloat, _ amount: Int, _ step: CGFloat, _ dur: CGFloat) {
		var a = amp, actions: [SKAction] = []
		for _ in 0..<amount {
			let act = SKAction.moveBy(x: Bool.random() ? a : -a,
																y: Bool.random() ? a : -a, duration: TimeInterval(dur))
			act.timingMode = .easeOut
			actions.append(contentsOf: [act, act.reversed()])
			a -= step
		}
		node.run(SKAction.sequence(actions))
	}
}
