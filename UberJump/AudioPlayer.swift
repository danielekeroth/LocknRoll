//
//  AudioPlayer.swift
//  UberJump
//
//  Created by Daniel Ekeroth on 2016-04-18.
//  Copyright © 2016 Geekfox Consulting. All rights reserved.
//

import Foundation
import AVFoundation

public class AudioPlayer
{
    init(path: String,autoPlay: Bool,repeatForever: Bool,volume: Float,name: String)
    {
        self.Name = name
        self.Path = NSBundle.mainBundle().pathForResource(path, ofType:nil)!
        do {
            let sound = try AVAudioPlayer(contentsOfURL: URL())
            Player = sound
            if(autoPlay)
            {
                self.Play()
            }
            
            self.Player.volume = volume
            self.Player.numberOfLoops = repeatForever ? -1 : 0
        }
        catch {
            print("Audio playback failed")
        }
    }
    var Name: String
    var Player: AVAudioPlayer!
    var Path: String = ""
    func URL() -> NSURL {
        return NSURL(fileURLWithPath: Path)
    }
    func Stop() {
        if(Player != nil && Player.playing)
        {
            Player.stop()
        }
    }
    func Play() {
        if(Player != nil && !Player.playing)
        {
            Player.play()
        }
    }
    
}