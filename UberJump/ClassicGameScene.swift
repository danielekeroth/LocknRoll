//
//  GameController.swift
//  UberJump
//
//  Created by Daniel Ekeroth on 2016-04-19.
//  Copyright © 2016 Geekfox Consulting. All rights reserved.
//

import Foundation
import SpriteKit
import CoreGraphics
import Answers

extension SKScene {
    func videoPlaybackBeganInAd(ad: ALAd)
    {
        BGMusic.Player.pause()
        Answers.logCustomEventWithName("Ad Started", customAttributes: ["Ad Type":ad.type,"Ad Size":ad.size,"Ad ID":ad.adIdNumber])
    }
    
    func videoPlaybackEndedInAd(ad: ALAd, atPlaybackPercent percentPlayed: NSNumber, fullyWatched wasFullyWatched: Bool)
    {
        BGMusic.Player.play()
        Answers.logCustomEventWithName("Ad Ended", customAttributes: ["Fully Watched":wasFullyWatched,"Percentage Played":percentPlayed,"Ad Type":ad.type,"Ad Size":ad.size,"Ad ID":ad.adIdNumber])
    }
    
    internal func ShowAd() {
        ALInterstitialAd.show()
    }
}

class ClassicGameScene: SKScene,ALAdVideoPlaybackDelegate
{
    // Sprite Nodes
    var Helper : GameHelper
    
    override init() {
        if NSUserDefaults.standardUserDefaults().stringForKey("currentGameMode") == "Endless"
        {
            Helper = GameHelper(mode: .ClassicEndless)
            Answers.logLevelStart("Classic Endless", customAttributes: nil)
        }
        else if NSUserDefaults.standardUserDefaults().stringForKey("currentGameMode") == "Hardcore"
        {
            Helper = GameHelper(mode: .HardcoreClassic)
            Answers.logLevelStart("Classic Hardcore", customAttributes: nil)
        }
        else {
            Helper = GameHelper(mode: .Classic)
            Answers.logLevelStart("Classic", customAttributes: nil)
        }
        super.init()
        Helper.GameScene = self
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        if NSUserDefaults.standardUserDefaults().stringForKey("currentGameMode") == "Endless"
        {
            Helper = GameHelper(mode: .ClassicEndless)
            Answers.logLevelStart("Classic Endless", customAttributes: nil)
        }
        else if NSUserDefaults.standardUserDefaults().stringForKey("currentGameMode") == "Hardcore"
        {
            Helper = GameHelper(mode: .HardcoreClassic)
            Answers.logLevelStart("Classic Hardcore", customAttributes: nil)
        }
        else {
            Helper = GameHelper(mode: .Classic)
            Answers.logLevelStart("Classic", customAttributes: nil)
        }
        super.init(coder: aDecoder)
        Helper.GameScene = self
    }
    
    override required init(size: CGSize)
    {
        if NSUserDefaults.standardUserDefaults().stringForKey("currentGameMode") == "Endless"
        {
            Helper = GameHelper(mode: .ClassicEndless)
            Answers.logLevelStart("Classic Endless", customAttributes: nil)
        }
        else if NSUserDefaults.standardUserDefaults().stringForKey("currentGameMode") == "Hardcore"
        {
            Helper = GameHelper(mode: .HardcoreClassic)
            Answers.logLevelStart("Classic Hardcore", customAttributes: nil)
        }
        else {
            Helper = GameHelper(mode: .Classic)
            Answers.logLevelStart("Classic", customAttributes: nil)
        }
        super.init(size: size)
        Helper.GameScene = self
    }
    
    override func didMoveToView(view: SKView) {
        ALInterstitialAd.shared().adVideoPlaybackDelegate = self;
        Helper.LoadSettings()
        Helper.LoadView()
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        
        if Helper.Person.intersectsNode(Helper.Dot){
            Helper.intersected = true
            
        }
        else{
            if Helper.intersected == true{
                if Helper.Person.intersectsNode(Helper.Dot) == false{
                    Helper.died()
                }
            }
        }
    }
}
