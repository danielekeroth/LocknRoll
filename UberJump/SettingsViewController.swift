//
//  SettingsViewController.swift
//  UberJump
//
//  Created by Daniel Ekeroth on 2016-04-19.
//  Copyright © 2016 Geekfox Consulting. All rights reserved.
//

import Foundation
import UIKit
import LTMorphingLabel
import TVOSToast

class FocusableText: UILabel {
    
    var data: String?
    var parentView: UIViewController?
    
    
    override func canBecomeFocused() -> Bool {
        return true
    }
    
    override func didUpdateFocusInContext(context: UIFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {
        
        if context.nextFocusedView == self {
            coordinator.addCoordinatedAnimations({ () -> Void in
                self.layer.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.2).CGColor
                }, completion: nil)
        } else if context.previouslyFocusedView == self {
            coordinator.addCoordinatedAnimations({ () -> Void in
                self.layer.backgroundColor = UIColor.clearColor().CGColor
                }, completion: nil)
        }
    }
    
}

class SettingsViewController: GameViewController
{
    @IBAction func resetProgressButton(sender: AnyObject) {
        let alert = UIAlertController(title: "Reset settings & progress?", message: "", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Confirm", style: UIAlertActionStyle.Destructive, handler: {(alert: UIAlertAction!) in
            for setting in SettingsHelper.Highscores
            {
                NSUserDefaults.standardUserDefaults().setInteger(0, forKey: setting)
            }
            let toast = TVOSToast(frame: CGRect(x: 0, y: 0, width: 800, height: 140))
            toast.style.position = TVOSToastPosition.Bottom(insets: 20)
            toast.hintText = TVOSToastHintText(elements: "Your progress has been reset.")
            self.presentToast(toast)
        }))
        self.showViewController(alert, sender: self)
    }
    
    @IBOutlet weak var selectedGameModeLabel: LTMorphingLabel!
    @IBOutlet weak var selectedBGMusicLabel: LTMorphingLabel!
    @IBOutlet weak var soundFXVolumeBar: UIProgressView!
    @IBOutlet weak var musicVolumeBar: UIProgressView!
    @IBOutlet weak var soundFXVolumeLabel: FocusableText!
    @IBOutlet weak var gameModeLabel: FocusableText!
    @IBOutlet weak var bgMusicLabel: FocusableText!
    @IBOutlet weak var musicVoulmeLabel: FocusableText!
    
    var currentGameMode = ""
    
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.Right:
                if soundFXVolumeLabel.focused
                {
                    if soundFXVolumeBar.progress < 1.0
                    {
                        soundFXVolumeBar.progress += 0.1
                        NSUserDefaults.standardUserDefaults().setFloat(musicVolumeBar.progress, forKey: SettingsHelper.SFXVolume)
                    }
                }
                else if musicVoulmeLabel.focused
                {
                    if musicVolumeBar.progress < 1.0
                    {
                        musicVolumeBar.progress += 0.1
                        BGMusic.Player.volume = musicVolumeBar.progress
                        NSUserDefaults.standardUserDefaults().setFloat(musicVolumeBar.progress, forKey: SettingsHelper.MusicVolume)
                    }
                }
                else if gameModeLabel.focused
                {
                    let currentIndex = AvailableGameModes.indexOf(self.currentGameMode)
                    var nextIndex = currentIndex!+1
                    if nextIndex == AvailableGameModes.endIndex
                    {
                        nextIndex = 0
                    }
                    self.currentGameMode = AvailableGameModes[nextIndex]
                    self.selectedGameModeLabel.text = self.currentGameMode
                    NSUserDefaults.standardUserDefaults().setObject(currentGameMode, forKey: SettingsHelper.GameMode)
                }
                else if bgMusicLabel.focused
                {
                    let currentSongIndex = Global.BackgroundMusic.indexOf({$0.Name == BGMusic.Name})
                    let newSong = currentSongIndex < Global.BackgroundMusic.count-1 ? Global.BackgroundMusic[currentSongIndex!+1] : Global.BackgroundMusic.first!
                    NSUserDefaults.standardUserDefaults().setObject(newSong.Name, forKey: SettingsHelper.BGMusic)
                    BGMusic = AudioPlayer(path: newSong.Path,autoPlay: true,repeatForever: true,volume: NSUserDefaults.standardUserDefaults().floatForKey(SettingsHelper.MusicVolume),name: newSong.Name)
                    selectedBGMusicLabel.text = newSong.Name
                }
            case UISwipeGestureRecognizerDirection.Left:
                if bgMusicLabel.focused {
                    let currentSongIndex = Global.BackgroundMusic.indexOf({$0.Name == BGMusic.Name})
                    let newSong = currentSongIndex >= 1 ? Global.BackgroundMusic[currentSongIndex!-1] : Global.BackgroundMusic.last!
                    NSUserDefaults.standardUserDefaults().setObject(newSong.Name, forKey: SettingsHelper.BGMusic)
                    BGMusic = AudioPlayer(path: newSong.Path,autoPlay: true,repeatForever: true,volume: NSUserDefaults.standardUserDefaults().floatForKey(SettingsHelper.MusicVolume),name: newSong.Name)
                    selectedBGMusicLabel.text = newSong.Name
                }
                else if gameModeLabel.focused
                {
                    let currentIndex = AvailableGameModes.indexOf(currentGameMode)
                    var nextIndex = currentIndex!-1
                    if nextIndex < 0
                    {
                        nextIndex = AvailableGameModes.endIndex-1
                    }
                    currentGameMode = AvailableGameModes[nextIndex]
                    selectedGameModeLabel.text = currentGameMode
                    NSUserDefaults.standardUserDefaults().setObject(currentGameMode, forKey: SettingsHelper.GameMode)
                }
                else if soundFXVolumeLabel.focused
                {
                    if soundFXVolumeBar.progress > 0.0
                    {
                        soundFXVolumeBar.progress -= 0.1
                        NSUserDefaults.standardUserDefaults().setFloat(musicVolumeBar.progress, forKey: SettingsHelper.SFXVolume)
                    }
                }
                else if musicVoulmeLabel.focused
                {
                    if musicVolumeBar.progress > 0.0
                    {
                        musicVolumeBar.progress -= 0.1
                        BGMusic.Player.volume = musicVolumeBar.progress
                        NSUserDefaults.standardUserDefaults().setFloat(musicVolumeBar.progress, forKey: SettingsHelper.MusicVolume)
                    }
                }
            default:
                break
            }
        }
    }
    
    override func viewDidLoad() {
        NSUserDefaults.standardUserDefaults().setObject("Normal", forKey: SettingsHelper.GameMode)
        selectedGameModeLabel.morphingEffect = .Evaporate
        selectedGameModeLabel.morphingEnabled = true
        selectedBGMusicLabel.morphingEffect = .Scale
        selectedBGMusicLabel.morphingEnabled = true
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(SettingsViewController.respondToSwipeGesture(_:)))
        swipeRight.direction = UISwipeGestureRecognizerDirection.Right
        self.view.addGestureRecognizer(swipeRight)
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(SettingsViewController.respondToSwipeGesture(_:)))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.Left
        self.view.addGestureRecognizer(swipeLeft)
        selectedBGMusicLabel.text = NSUserDefaults.standardUserDefaults().stringForKey(SettingsHelper.BGMusic)
        currentGameMode = NSUserDefaults.standardUserDefaults().stringForKey(SettingsHelper.GameMode)!
        selectedGameModeLabel.text = currentGameMode
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
}
