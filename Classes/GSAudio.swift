//
//  GSAudio.swift
//  Jump
//
//  Created by debavlad on 09.11.2019.
//  Copyright © 2019 Vladislav Deba. All rights reserved.
//

import Foundation
import AVFoundation

class GSAudio: NSObject, AVAudioPlayerDelegate {
    static let sharedInstance = GSAudio()
    var players = [NSURL:AVAudioPlayer]()
    var duplicatePlayers = [AVAudioPlayer]()

    private override init() {}

    func playSound (soundFileName: String) {
        let soundFileNameURL = NSURL(fileURLWithPath: Bundle.main.path(forResource: soundFileName, ofType: "wav")!)
        if let player = players[soundFileNameURL] { //player for sound has been found
            if player.isPlaying == false { //player is not in use, so use that one
                player.prepareToPlay()
                player.play()
            } else { // player is in use, create a new, duplicate, player and use that instead
                let duplicatePlayer = try! AVAudioPlayer(contentsOf: soundFileNameURL as URL)
                //use 'try!' because we know the URL worked before.
                duplicatePlayer.delegate = self
                //assign delegate for duplicatePlayer so delegate can remove the duplicate once it's stopped playing
                duplicatePlayers.append(duplicatePlayer)
                //add duplicate to array so it doesn't get removed from memory before finishing
                duplicatePlayer.prepareToPlay()
                duplicatePlayer.play()
            }
        } else { //player has not been found, create a new player with the URL if possible
            do {
                let player = try AVAudioPlayer(contentsOf: soundFileNameURL as URL)
                players[soundFileNameURL] = player
                player.prepareToPlay()
                player.play()
            } catch {
                print("Could not play sound file!")
            }
        }
    }


    func playSounds(soundFileNames: [String]) {
        for soundFileName in soundFileNames {
            playSound(soundFileName: soundFileName)
        }
    }

    func playSounds(soundFileNames: String...) {
        for soundFileName in soundFileNames {
            playSound(soundFileName: soundFileName)
        }
    }

    func playSounds(soundFileNames: [String], withDelay: Double) { //withDelay is in seconds
        for (index, soundFileName) in soundFileNames.enumerated() {
            let delay = withDelay*Double(index)
            let _ = Timer.scheduledTimer(timeInterval: delay, target: self, selector: #selector(playSoundNotification), userInfo: ["fileName":soundFileName], repeats: false)
        }
    }

    @objc func playSoundNotification(notification: NSNotification) {
        if let soundFileName = notification.userInfo?["fileName"] as? String {
            playSound(soundFileName: soundFileName)
        }
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        duplicatePlayers.remove(at: duplicatePlayers.firstIndex(of: player)!)
        //Remove the duplicate player once it is done
    }
}
