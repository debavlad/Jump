//
//  Stage.swift
//  Jump
//
//  Created by debavlad on 15.01.2020.
//  Copyright © 2020 Vladislav Deba. All rights reserved.
//

import Foundation
import SpriteKit

class Stage {
	var current = 0
	var platforms: Set<PlatformType>
	var coins: Set<Currency>
//	var platforms: [PlatformType]
//	var coins: [Currency]
    
	init() {
		platforms = [.sand]
		coins = [.wood]
	}
    
	func upgrade(_ stage: Int) {
		switch (stage) {
		case 1:
			current = 1
			platforms.insert(.wood)
			coins.insert(.bronze)
			PlatformFactory.foodFrequency = 4
		case 2:
			current = 2
			platforms.insert(.stone)
			platforms.insert(.dirt)
			PlatformFactory.foodFrequency = 5
		case 3:
			current = 3
			coins.insert(.golden)
		default: break
		}
	}
}
