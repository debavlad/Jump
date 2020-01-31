//
//  Variables.swift
//  Jump
//
//  Created by debavlad on 14.11.2019.
//  Copyright © 2019 Vladislav Deba. All rights reserved.
//

import Foundation
import SpriteKit

class Fonts {
	static let forwa = "FFFForward"
	static let pixelf = "pixelFJ8pt1"
	static let droid = "DisposableDroidBB"
}

var bounds: Bounds!

class Bit {
	static let player: UInt32 = 0x1 << 1
	static let coin: UInt32 = 0x1 << 2
	static let food: UInt32 = 0x1 << 3
	static let ground: UInt32 = 0x1 << 4
	static let platform: UInt32 = 0x1 << 5
	static let rock: UInt32 = 0x1 << 6
	static let bird: UInt32 = 0x1 << 7
	static let trampoline: UInt32 = 0x1 << 8
	static let potion: UInt32 = 0x1 << 9
}
