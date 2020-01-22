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
	var id, foodFreq: Int
	var blocks: Set<BlockType>
	var coins: Set<Currency>
	
	init() {
		id = 0
		foodFreq = 3
		blocks = [.Sand]
		coins = [.Wood]
	}
	
	func upgrade(to stage: Int) {
		if stage <= 3 { id = stage; foodFreq += 1 }
		switch (stage) {
			case 1:
				blocks.insert(.Wooden)
				coins.insert(.Bronze)
			case 2:
				blocks.insert(.Stone)
				blocks.insert(.Dirt)
			case 3:
				coins.insert(.Golden)
			default: break
		}
	}
}
