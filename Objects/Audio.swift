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
	private init() {
		if UserDefaults.standard.object(forKey: "soundState") != nil {
			isEnabled = UserDefaults.standard.bool(forKey: "soundState")
		} else {
			isEnabled = true
		}
	}
	
	var isEnabled: Bool
	
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
		if isEnabled {
			node.run(SKAction.playSoundFileNamed(sound, waitForCompletion: false))
		}
	}
	
	func start() {
		player?.play()
		player?.setVolume(1, fadeDuration: 10)
		isEnabled = true
	}
	
	func stop() {
		player?.stop()
		isEnabled = false
	}
}
