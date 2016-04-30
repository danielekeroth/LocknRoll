//
//  AchievementHelper.swift
//  LocknRoll
//
//  Created by Daniel Ekeroth on 2016-04-24.
//  Copyright © 2016 Geekfox Consulting. All rights reserved.
//

import Foundation

public let AvailableGameModes = ["Normal","Hardcore","Endless"]
public func SelectedGameMode() -> String {
    return NSUserDefaults.standardUserDefaults().stringForKey("currentGameMode")!
}

public class Leaderboards {
    static let Classic = "com.geekfox.locknroll.classic"
    static let Modern = "com.geekfox.locknroll.modern"
    static let ClassicHardcore = "com.geekfox.locknroll.hardcoreclassic"
    static let ModernHardcore = "com.geekfox.locknroll.hardcoremodern"
    static let ClassicEndless = "com.geekfox.locknroll.endlessclassic"
    static let ModernEndless = "com.geekfox.locknroll.endlessmodern"
}

public class AchievementHelper {
    static let TenLocksAchievementID = "com.geekfox.locknroll.10"
    static let TwentyFiveLocksAchievementID = "com.geekfox.locknroll.25"
    static let FiftyLocksAchievementID = "com.geekfox.locknroll.50"
    static let MixItUp = "com.geekfox.locknroll.mixitup"
}