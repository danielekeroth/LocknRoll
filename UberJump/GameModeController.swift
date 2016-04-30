//
//  GameModeController.swift
//  UberJump
//
//  Created by Daniel Ekeroth on 2016-04-22.
//  Copyright © 2016 Geekfox Consulting. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit

class GameModeController: UIViewController {
    @IBOutlet weak var hardcoreImage2: UIImageView!
    @IBOutlet weak var hardcoreImage: UIImageView!
    @IBOutlet weak var endlessLabel: UILabel!
    @IBOutlet weak var hardcoreLabel: UILabel!
    @IBOutlet weak var classicGameModeButton: PosterButton!
    @IBOutlet weak var modernGameModeButton: PosterButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        if NSUserDefaults.standardUserDefaults().stringForKey("currentGameMode") == "Endless"
        {
            endlessLabel.alpha = 1.0
        }
        else if NSUserDefaults.standardUserDefaults().stringForKey("currentGameMode") == "Hardcore"
        {
            hardcoreLabel.alpha = 1.0
            hardcoreImage.alpha = 1.0
            hardcoreImage2.alpha = 1.0
        }
        classicGameModeButton.titleLabelText = "Classic"
        classicGameModeButton.posterImage = UIImage.init(named: "classicIcon")
        classicGameModeButton.addTarget(self, action: #selector(GameModeController.classicButtonPressed), forControlEvents: .PrimaryActionTriggered)
        modernGameModeButton.titleLabelText = "Modern"
        modernGameModeButton.posterImage = UIImage.init(named: "modernIcon")
        modernGameModeButton.addTarget(self, action: #selector(GameModeController.modernButtonPressed), forControlEvents: .PrimaryActionTriggered)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let destination = segue.destinationViewController as? GameController {
            destination.segueId = segue.identifier == "ClassicGameSegue" ? "Classic" : "Modern"
        }
    }
    
    func modernButtonPressed() {
        self.performSegueWithIdentifier("ModernGameSegue", sender: nil)
    }
    
    
    func classicButtonPressed() {
        self.performSegueWithIdentifier("ClassicGameSegue", sender: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
}