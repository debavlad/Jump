//
//  GSAudio.swift
//  Jump
//
//  Created by debavlad on 09.11.2019.
//  Copyright © 2019 Vladislav Deba. All rights reserved.
//

import Foundation
import AVFoundation
import AudioToolbox

class Audio {
	static let shared = Audio()
	
	func playSound(_ soundName: String) {
		DispatchQueue.global(qos: .background).async {
			guard let url = Bundle.main.url(forResource: soundName, withExtension: "wav") else { return }
			var s: SystemSoundID = 0
			AudioServicesCreateSystemSoundID(url as CFURL, &s)
			AudioServicesPlaySystemSound(s)
		}
	}
	
	func playSounds(_ soundFileNames: String...) {
		for name in soundFileNames {
			playSound(name)
		}
	}
}
