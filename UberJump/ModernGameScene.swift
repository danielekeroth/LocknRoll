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

class ModernGameScene: SKScene,ALAdVideoPlaybackDelegate
{
    // Sprite Nodes
    var Helper : GameHelper
    

    
    override init() {
        if NSUserDefaults.standardUserDefaults().stringForKey("currentGameMode") == "Endless"
        {
            Helper = GameHelper(mode: GameModes.ModernEndless)
            Answers.logLevelStart("Modern", customAttributes: ["Mode":"Endless"])
        }
        else if NSUserDefaults.standardUserDefaults().stringForKey("currentGameMode") == "Hardcore"
        {
            Helper = GameHelper(mode: GameModes.HardcoreModern)
            Answers.logLevelStart("Modern", customAttributes: ["Mode":"Hardcore"])
        }
        else {
            Helper = GameHelper(mode: GameModes.Modern)
            Answers.logLevelStart("Modern", customAttributes: ["Mode":"Normal"])
        }
        super.init()
        Helper.GameScene = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        if NSUserDefaults.standardUserDefaults().stringForKey("currentGameMode") == "Endless"
        {
            Helper = GameHelper(mode: GameModes.ModernEndless)
            Answers.logLevelStart("Modern", customAttributes: ["Mode":"Endless"])
        }
        else if NSUserDefaults.standardUserDefaults().stringForKey("currentGameMode") == "Hardcore"
        {
            Helper = GameHelper(mode: GameModes.HardcoreModern)
            Answers.logLevelStart("Modern", customAttributes: ["Mode":"Hardcore"])
        }
        else {
            Helper = GameHelper(mode: GameModes.Modern)
            Answers.logLevelStart("Modern", customAttributes: ["Mode":"Normal"])
        }
        super.init(coder: aDecoder)
        Helper.GameScene = self
    }
    
    override required init(size: CGSize)
    {
        if NSUserDefaults.standardUserDefaults().stringForKey("currentGameMode") == "Endless"
        {
            Helper = GameHelper(mode: GameModes.ModernEndless)
            Answers.logLevelStart("Modern", customAttributes: ["Mode":"Endless"])
        }
        else if NSUserDefaults.standardUserDefaults().stringForKey("currentGameMode") == "Hardcore"
        {
            Helper = GameHelper(mode: GameModes.HardcoreModern)
            Answers.logLevelStart("Modern", customAttributes: ["Mode":"Hardcore"])
        }
        else {
            Helper = GameHelper(mode: GameModes.Modern)
            Answers.logLevelStart("Modern", customAttributes: ["Mode":"Normal"])
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
        if Helper.Person.intersectsNode(Helper.Range){
            Helper.intersected = true
        }
        else{
            if Helper.intersected == true{
                if Helper.Person.intersectsNode(Helper.Range) == false{
                    Helper.died()
                }
            }
        }
    }
}
