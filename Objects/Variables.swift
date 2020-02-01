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
}

var bounds: Bounds!

struct Bit {
	static let player: UInt32 = 0x1 << 1
	static let platform: UInt32 = 0x1 << 2
	static let ground: UInt32 = 0x1 << 3
	static let item: UInt32 = 0x1 << 4
	static let bird: UInt32 = 0x1 << 5
}
