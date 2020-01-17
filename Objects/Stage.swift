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
	var foodFreq: Int
//	var platforms: [PlatformType]
//	var coins: [Currency]
    
	init() {
		platforms = [.sand]
		coins = [.wood]
		foodFreq = 3
	}
    
	func upgrade(_ stage: Int) {
		switch (stage) {
		case 1:
			current = 1
			platforms.insert(.wooden)
			coins.insert(.bronze)
			foodFreq = 4
		case 2:
			current = 2
			platforms.insert(.stone)
			platforms.insert(.dirt)
			foodFreq = 5
		case 3:
			current = 3
			coins.insert(.golden)
		default: break
		}
	}
}
