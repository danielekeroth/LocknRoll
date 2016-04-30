//
//  Globals.swift
//  UberJump
//
//  Created by Daniel Ekeroth on 2016-04-19.
//  Copyright © 2016 Geekfox Consulting. All rights reserved.
//

import Foundation
import UIKit
import TVOSButton
import SpriteKit
import GameKit
import Crashlytics
import Answers

var BGMusic: AudioPlayer!
var Global = Globals()
var GCHelper = GameCenterHelper()

extension SKAction {
    class func shake(initialPosition:CGPoint, duration:Float, amplitudeX:Int = 12, amplitudeY:Int = 3) -> SKAction {
        let startingX = initialPosition.x
        let startingY = initialPosition.y
        let numberOfShakes = duration / 0.015
        var actionsArray:[SKAction] = []
        for _ in 1...Int(numberOfShakes) {
            let newXPos = startingX + CGFloat(arc4random_uniform(UInt32(amplitudeX))) - CGFloat(amplitudeX / 2)
            let newYPos = startingY + CGFloat(arc4random_uniform(UInt32(amplitudeY))) - CGFloat(amplitudeY / 2)
            actionsArray.append(SKAction.moveTo(CGPointMake(newXPos, newYPos), duration: 0.015))
        }
        actionsArray.append(SKAction.moveTo(initialPosition, duration: 0.015))
        return SKAction.sequence(actionsArray)
    }
}

class PosterButton: TVOSButton {
    
    var posterImage: UIImage? {
        didSet {
            badgeImage = posterImage
        }
    }
    
    var posterImageURL: String? {
        didSet {
            if let posterImageURL = posterImageURL {
                NSURLSession.sharedSession().dataTaskWithURL(
                    NSURL(string: posterImageURL)!,
                    completionHandler: { data, response, error in
                        if error == nil {
                            if let data = data, image = UIImage(data: data) {
                                dispatch_async(dispatch_get_main_queue(), {
                                    self.posterImage = image
                                })
                            }
                        }
                }).resume()
            }
        }
    }
    
    override func tvosButtonStyleForState(tvosButtonState: TVOSButtonState) -> TVOSButtonStyle {
        switch tvosButtonState {
        case .Focused:
            return TVOSButtonStyle(
                scale: 1.1,
                shadow: TVOSButtonShadow.Focused,
                badgeStyle: TVOSButtonImage.Fill(adjustsImageWhenAncestorFocused: true),
                titleStyle: TVOSButtonLabel.DefaultTitle(color: UIColor.whiteColor()))
        case .Highlighted:
            return TVOSButtonStyle(
                scale: 0.95,
                shadow: TVOSButtonShadow.Highlighted,
                badgeStyle: TVOSButtonImage.Fill(adjustsImageWhenAncestorFocused: true),
                titleStyle: TVOSButtonLabel.DefaultTitle(color: UIColor.whiteColor()))
        default:
            return TVOSButtonStyle(
                badgeStyle: TVOSButtonImage.Fill(adjustsImageWhenAncestorFocused: true),
                titleStyle: TVOSButtonLabel.DefaultTitle(color: UIColor.blackColor()))
        }
    }
}

public enum GameModes:String {
    case Modern = "Modern"
    case HardcoreModern = "HCModern"
    case Classic = "Classic"
    case HardcoreClassic = "HCClassic"
    case ModernEndless = "ModernEndless"
    case ClassicEndless = "ClassicEndless"
    static let allValues = [Modern,HardcoreModern,Classic,HardcoreClassic,ModernEndless,ClassicEndless]
}

public class GameCenterHelper: NSObject,GKGameCenterControllerDelegate
{
    func isPlayerAuthenticated() -> Bool {
        let localPlayer = GKLocalPlayer.localPlayer()
        return localPlayer.authenticated
    }
    
    func authPlayer(view: UIView) {
        let localPlayer = GKLocalPlayer.localPlayer()
        localPlayer.authenticateHandler = {
            (view,error) in
            if view != nil {
                view!.parentViewController!.presentViewController(view!, animated: true, completion: nil)
            }
        }
    }
    
    func StoreAchievement(achievementId: String)
    {
        if GKLocalPlayer.localPlayer().authenticated {
            let achieve = GKAchievement(identifier: achievementId)
            achieve.percentComplete = 100.00
            var achieveArray = [GKAchievement]()
            achieveArray.append(achieve)
            GKAchievement.reportAchievements(achieveArray, withCompletionHandler: { (error : NSError?) -> Void in
                
            })
        }
    }
    
    func StoreAchievement(achievementId: String,number: Int,goal: Int)
    {
        if GKLocalPlayer.localPlayer().authenticated {
            let achieve = GKAchievement(identifier: achievementId)
            let percent = Double((number/goal)*100)
            achieve.percentComplete = percent > 100.00 ? 100.00 : percent
            var achieveArray = [GKAchievement]()
            achieveArray.append(achieve)
            GKAchievement.reportAchievements(achieveArray, withCompletionHandler: { (error : NSError?) -> Void in
                //print(error!.localizedDescription)
            })
        }
    }
    
    func saveHighScore(number: Int,leaderboardId: String) {
        if GKLocalPlayer.localPlayer().authenticated {
            let scoreReporter = GKScore(leaderboardIdentifier: leaderboardId)
            scoreReporter.value = Int64(number)
            let scoreArray : [GKScore] = [scoreReporter]
            GKScore.reportScores(scoreArray, withCompletionHandler: nil)
        }
    }
    
    func showLeaderboard(viewController: GameViewController) {
        let gcvc = GKGameCenterViewController()
        gcvc.gameCenterDelegate = self
        viewController.presentViewController(gcvc, animated: true, completion: nil)
        Answers.logCustomEventWithName("Showed Leaderboard", customAttributes: nil)
    }
    
    public func gameCenterViewControllerDidFinish(gameCenterViewController: GKGameCenterViewController)
    {
        gameCenterViewController.dismissViewControllerAnimated(true, completion: nil)
    }
}

public class Globals
{
    var BackgroundMusic = [Sound]();
    
    public enum DifficultiesEnum {
        case Classic,Modern
    }
    
    func toggleMute(sender: UIButton) {
        // Muting
        if(BGMusic.Player.volume > 0)
        {
            BGMusic.Player.volume = 0
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "isMuted")
            sender.setBackgroundImage(UIImage.init(named: "SoundOff-Normal"), forState: UIControlState.Normal)
            sender.setBackgroundImage(UIImage.init(named: "SoundOff-Highlighted"), forState: UIControlState.Focused)
        }
        else
        {
            BGMusic.Player.volume = NSUserDefaults.standardUserDefaults().floatForKey("Volume")
            NSUserDefaults.standardUserDefaults().setBool(false, forKey: "isMuted")
            BGMusic.Player.play()
            sender.setBackgroundImage(UIImage.init(named: "SoundOn-Normal"), forState: UIControlState.Normal)
            sender.setBackgroundImage(UIImage.init(named: "SoundOn-Highlighted"), forState: UIControlState.Focused)
        }
    }
    
    func checkMute(sender: UIButton) {
        if(NSUserDefaults.standardUserDefaults().boolForKey("isMuted"))
        {
            sender.setBackgroundImage(UIImage.init(named: "SoundOff-Normal"), forState: UIControlState.Normal)
            sender.setBackgroundImage(UIImage.init(named: "SoundOff-Highlighted"), forState: UIControlState.Focused)
        }
    }
}