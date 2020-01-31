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
		easing = 0.082
	}
	
	func punch(_ amp: CGFloat) {
		let x = Bool.random() ? amp : -amp
		let a = SKAction.moveBy(x: x, y: -amp, duration: 0.12)
		a.timingMode = .easeOut
		node.run(SKAction.sequence([a, a.reversed()]))
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
	
	func shake(_ node: SKNode, _ amp: CGFloat, _ amount: Int, _ step: CGFloat, _ dur: CGFloat) {
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
