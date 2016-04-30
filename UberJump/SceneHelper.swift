//
//  SceneHelper.swift
//  LocknRoll
//
//  Created by Daniel Ekeroth on 2016-04-30.
//  Copyright © 2016 Geekfox Consulting. All rights reserved.
//

import Foundation

public class SceneHelper {
    static func InitializeGameScene(gameMode: String) -> GameHelper{
        var ret : GameHelper
        if NSUserDefaults.standardUserDefaults().stringForKey("currentGameMode") == "Endless"
        {
            ret = GameHelper(mode: gameMode == "Classic" ? .ClassicEndless : .ModernEndless)
            Answers.logLevelStart(gameMode + " Endless", customAttributes: nil)
        }
        else if NSUserDefaults.standardUserDefaults().stringForKey("currentGameMode") == "Hardcore"
        {
            ret = GameHelper(mode: gameMode == "Classic" ? .HardcoreClassic : .HardcoreModern)
            Answers.logLevelStart(gameMode + " Hardcore", customAttributes: nil)
        }
        else {
            ret = GameHelper(mode: gameMode == "Classic" ? .Classic : .Modern)
            Answers.logLevelStart(gameMode, customAttributes: nil)
        }
        return ret
    }
}