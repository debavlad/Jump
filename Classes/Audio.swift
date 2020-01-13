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
		if !SOUND_ENABLED { return }
		DispatchQueue.global(qos: .background).async {
			guard let soundURL = Bundle.main.url(forResource: soundName, withExtension: "wav") else { return }
			var s: SystemSoundID = 0
			AudioServicesCreateSystemSoundID(soundURL as CFURL, &s)
			AudioServicesPlaySystemSound(s);
		}
	}
	
	static func playSounds(_ soundFileNames: String...) {
		if !SOUND_ENABLED { return }
		for soundFileName in soundFileNames {
			playSound(soundFileName)
		}
	}
}
