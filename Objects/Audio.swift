//
//  Audio.swift
//  Jump
//
//  Created by debavlad on 01.02.2020.
//  Copyright © 2020 Vladislav Deba. All rights reserved.
//

import Foundation
import AVFoundation
import SpriteKit

class Audio {
	static let shared = Audio()
	
	private lazy var player: AVAudioPlayer? = {
		guard let url = Bundle.main.url(forResource: "background", withExtension: "mp3") else {
			return nil
		}
		do {
			let tmp = try AVAudioPlayer(contentsOf: url)
			tmp.numberOfLoops = -1
			tmp.volume = 0
			return tmp
		} catch { return nil }
	}()
	
	func play(_ sound: String, _ node: SKNode) {
		node.run(SKAction.playSoundFileNamed(sound, waitForCompletion: false))
	}
	
	func start() {
		player?.play()
		player?.setVolume(1, fadeDuration: 10)
	}
}
