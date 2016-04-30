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

class AllGameScene : SKScene,ALAdVideoPlaybackDelegate
{
    // Sprite Nodes
    var Helper : GameHelper?
    
    override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(size: CGSize,mode: String)
    {
        Helper = SceneHelper.InitializeGameScene(mode)
        super.init(size: size)
        Helper!.GameScene = self
    }
    
    override func didMoveToView(view: SKView) {
        ALInterstitialAd.shared().adVideoPlaybackDelegate = self;
        Helper!.LoadSettings()
        Helper!.LoadView()
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        if Helper!.Person.intersectsNode(Helper!.Range){
            Helper!.intersected = true
        }
        else if Helper!.intersected == true && Helper!.Person.intersectsNode(Helper!.Range) == false
        {
            Helper!.died()
        }
    }
}
