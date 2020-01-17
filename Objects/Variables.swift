//
//  Variables.swift
//  Jump
//
//  Created by debavlad on 14.11.2019.
//  Copyright © 2019 Vladislav Deba. All rights reserved.
//

import Foundation
import SpriteKit
import AudioToolbox

var bounds: Bounds!

class Fonts {
	static let forwa = "FFFForward"
	static let pixelf = "pixelFJ8pt1"
	static let droid = "DisposableDroidBB"
}

let Skins = [
	Skin(name: "pauper", title: "Pauper", dsc: "Default", 0, .wood, colors: [Colors.pa1, Colors.pa2]),
	Skin(name: "zombie", title: "Zombie", dsc: "150 hp", 60, .wood, colors: [Colors.zo1, Colors.zo2]),
	Skin(name: "farmer", title: "Farmer", dsc: "Food x1.25", 80, .wood, colors: [Colors.fa1, Colors.fa2]),
	Skin(name: "bman", title: "Businessman", dsc: "Has 100 pts", 40, .bronze, colors: [UIColor.white, Colors.bu1, Colors.bu2]),
	Skin(name: "ninja", title: "Ninja", dsc: "Jump x1.25", 20, .golden, colors: [Colors.ni1, UIColor.gray, Colors.ni2, Colors.ni3])
]

let ADMOB_AD_ID = "ca-app-pub-5695778104677732/8877221005"
let TEST_AD_ID = "ca-app-pub-3940256099942544/1712485313"
var SOUND_ENABLED: Bool!

class Colors {
	static let red = UIColor(red: 231/255, green: 57/255, blue: 43/255, alpha: 1)
	static let yellow = UIColor(red: 235/255, green: 216/255, blue: 3/255, alpha: 1)
	static let green = UIColor(red: 0/255, green: 173/255, blue: 2/255, alpha: 1)
	static let pa1 = UIColor(red: 111/255, green: 123/255, blue: 131/255, alpha: 1)
	static let pa2 = UIColor(red: 137/255, green: 153/255, blue: 163/255, alpha: 1)
	static let fa1 = UIColor(red: 188/255, green: 72/255, blue: 53/255, alpha: 1)
	static let fa2 = UIColor(red: 55/255, green: 57/255, blue: 69/255, alpha: 1)
	static let zo1 = UIColor(red: 38/255, green: 150/255, blue: 125/255, alpha: 1)
	static let zo2 = UIColor(red: 199/255, green: 88/255, blue: 85/255, alpha: 1)
	static let bu1 = UIColor(red: 61/255, green: 49/255, blue: 40/255, alpha: 1)
	static let bu2 = UIColor(red: 157/255, green: 81/255, blue: 91/255, alpha: 1)
	static let ni1 = UIColor(red: 40/255, green: 44/255, blue: 44/255, alpha: 1)
	static let ni2 = UIColor(red: 196/255, green: 54/255, blue: 73/255, alpha: 1)
	static let ni3 = UIColor(red: 154/255, green: 42/255, blue: 58/255, alpha: 1)
}

class Categories {
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

class Collision {
	static let playerPlatform = Categories.player | Categories.platform
	static let playerGround = Categories.player | Categories.ground
	static let playerCoin = Categories.player | Categories.coin
	static let playerFood = Categories.player | Categories.food
	static let playerBird = Categories.player | Categories.bird
	static let playerTrampoline = Categories.player | Categories.trampoline
	static let playerPotion = Categories.player | Categories.potion
}
