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
	static func playSound(_ soundName: String) {
		if SOUND_ENABLED {
			DispatchQueue.global(qos: .background).async {
				if let soundURL = Bundle.main.url(forResource: soundName, withExtension: "wav") {
						var mySound: SystemSoundID = 0
						AudioServicesCreateSystemSoundID(soundURL as CFURL, &mySound)
						AudioServicesPlaySystemSound(mySound);
				}
			}
		}
	}
	
	static func playSounds(_ soundFileNames: String...) {
		if SOUND_ENABLED {
			for soundFileName in soundFileNames { playSound(soundFileName) }
		}
	}
}
