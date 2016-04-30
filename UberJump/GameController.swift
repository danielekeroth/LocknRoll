//
//  ModernGameController.swift
//  UberJump
//
//  Created by Daniel Ekeroth on 2016-04-21.
//  Copyright © 2016 Geekfox Consulting. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit
import Fabric
import Crashlytics

class GameController: UIViewController {
    var segueId = "";
    override func viewDidLoad() {
        super.viewDidLoad()
        if NSUserDefaults.standardUserDefaults().boolForKey("modernPlayed") == true && NSUserDefaults.standardUserDefaults().boolForKey("classicPlayed") == true {
            GCHelper.StoreAchievement(AchievementHelper.MixItUp)
        }
        if segueId == "Modern"
        {
            (self.view as! SKView).presentScene(ModernGameScene(size: self.view.bounds.size))
        }
        else if segueId == "Classic"
        {
            (self.view as! SKView).presentScene(ClassicGameScene(size: self.view.bounds.size))
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
}
