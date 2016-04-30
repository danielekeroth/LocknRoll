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
        (self.view as! SKView).presentScene(AllGameScene(size: self.view.bounds.size, mode: segueId))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
}
