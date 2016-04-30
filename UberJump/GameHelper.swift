//
//  GameHelper.swift
//  LocknRoll
//
//  Created by Daniel Ekeroth on 2016-04-24.
//  Copyright © 2016 Geekfox Consulting. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit
import AVKit
import GameKit

public class GameHelper
{
    
    init(mode: GameModes){
        self.gameMode = mode
    }
    // Variables and Properties
    var GameScene = SKScene()
    var gameMode : GameModes
    var scoreHolder = UIStackView()
    var FirstDigit = NumberMorphView()
    var SecondDigit = NumberMorphView()
    var ThirdDigit = NumberMorphView()
    var deaths = 0
    var numberOfClicks = 0
    var intersected = false
    var Path = UIBezierPath()
    var currentLevel = Int()
    var currentScore = Int()
    var highLevel = Int()
    var LevelLabel = UILabel()
    var HighscoreLabel = UILabel()
    var gameSpeed = CGFloat(400)
    
    // Color variables
    var colors = [UIColor]()
    var currentColor = UIColor()
    var toColor = UIColor()
    var dotColor = UIColor()
    var ringColor = UIColor()
    var playerColor = UIColor()
    var currentColorIndex = 0
    
    
    // Game Objects
    var Circle = SKSpriteNode()
    var Person = SKShapeNode()
    var Dot = SKShapeNode()
    var Dial = SKSpriteNode()
    var Digits = SKSpriteNode()
    var Arrow = SKSpriteNode()
    var Range = SKSpriteNode()
    var Outer = SKSpriteNode()
    var Lock = SKSpriteNode()
    var PauseOverlay = SKSpriteNode()
    var Canvas = SKSpriteNode()
    var HighscoreKey = ""
    var currentGameMode = ""
    var totalClicks = 0
    
    // States
    var movingClockwise = Bool()
    var gameStarted = Bool()
    var gamePaused = false
    
    func ColorizeCanvas()
    {
        var nextColorIndex = currentColorIndex+1
        if nextColorIndex == colors.endIndex {
            nextColorIndex = 0
        }
        self.currentColor = colors[nextColorIndex]
        currentColorIndex = nextColorIndex
        
        let contrastValue = (self.currentColor.getComponents().r*299)+(self.currentColor.getComponents().g*587)+(self.currentColor.getComponents().b*114)
        if (contrastValue/1000) > 125
        {
            HighscoreLabel.textColor = UIColor.blackColor()
            LevelLabel.textColor = UIColor.blackColor()
            self.FirstDigit.fontColor = UIColor.blackColor()
            self.SecondDigit.fontColor = UIColor.blackColor()
            self.ThirdDigit.fontColor = UIColor.blackColor()
        }
        else
        {
            HighscoreLabel.textColor = UIColor.whiteColor()
            LevelLabel.textColor = UIColor.whiteColor()
            self.FirstDigit.fontColor = UIColor.whiteColor()
            self.SecondDigit.fontColor = UIColor.whiteColor()
            self.ThirdDigit.fontColor = UIColor.whiteColor()
        }
        let action = SKAction.colorizeWithColor(self.currentColor, colorBlendFactor: 1.0, duration: 1.2)
        self.Canvas.removeActionForKey("colorize")
        self.GameScene.runAction(action, withKey: "colorize")
    }
    
    func ShowAd() {
        self.deaths = 0
        self.numberOfClicks = 0
        switch gameMode
        {
        case .Classic,.ClassicEndless,.HardcoreClassic:
            let scene = self.GameScene as! ClassicGameScene
            scene.ShowAd()
        case .HardcoreModern,.Modern,.ModernEndless:
            let scene = self.GameScene as! ModernGameScene
            scene.ShowAd()
        }
    }
    
    func LoadSettings() {
        let Defaults = NSUserDefaults.standardUserDefaults() as NSUserDefaults!
        if Defaults.integerForKey(gameMode.rawValue + "Highscore") == 0 && !(gameMode == GameModes.ClassicEndless || gameMode == GameModes.ModernEndless) && !(gameMode == .HardcoreClassic || gameMode == .HardcoreModern)
        {
            Defaults.setInteger(1, forKey: gameMode.rawValue + "Highscore")
            self.highLevel = Defaults.integerForKey(gameMode.rawValue + "Highscore") as Int!
            self.currentLevel = self.highLevel
            self.currentScore = self.currentLevel
        }
        else if gameMode == GameModes.ClassicEndless || gameMode == GameModes.ModernEndless
        {
            self.highLevel = Defaults.integerForKey(gameMode.rawValue + "Highscore") as Int!
            self.currentLevel = 0
            self.currentScore = 0
        }
        else if gameMode == .HardcoreModern || gameMode == .HardcoreClassic
        {
            self.highLevel = Defaults.integerForKey(gameMode.rawValue + "Highscore") as Int!
            self.currentLevel = 1
            self.currentScore = 1
        }
        else
        {
            self.highLevel = Defaults.integerForKey(gameMode.rawValue + "Highscore") as Int!
            self.currentLevel = self.highLevel
            self.currentScore = self.currentLevel
        }
    }
    
    func LoadViewClassic() {
        Canvas = SKSpriteNode(color: SKColor.clearColor(), size: CGSize(width: GameScene.frame.width, height: GameScene.frame.height))
        Canvas.position = CGPoint.init(x: CGRectGetMidX(GameScene.frame), y: CGRectGetMidY(GameScene.frame))
        Canvas.zPosition = 1
        GameScene.addChild(Canvas)
        movingClockwise = true
        
        PauseOverlay = SKSpriteNode(imageNamed: "PauseOverlay")
        PauseOverlay.size = CGSize(width: GameScene.frame.width,height: GameScene.frame.height)
        PauseOverlay.position = CGPoint.init(x: CGRectGetMidX(GameScene.frame), y: CGRectGetMidY(GameScene.frame))
        PauseOverlay.alpha = 0.0
        PauseOverlay.zPosition = 300.0
        GameScene.addChild(PauseOverlay)
        
        Circle = SKSpriteNode(imageNamed: "circle-shadow")
        Circle.size = CGSize(width: 500, height: 500)
        Circle.position = CGPoint(x: CGRectGetMidX(GameScene.frame), y: CGRectGetMidY(GameScene.frame))
        Circle.zPosition = 2.0
        GameScene.addChild(Circle)
        
        Person = SKShapeNode.init(rectOfSize: CGSize(width:62,height:9), cornerRadius: 4)
        Person.fillColor = SKColor.init(red: 0.886, green: 0.231, blue: 0.231, alpha: 1.0)
        Person.strokeColor = SKColor.init(red: 0.886, green: 0.231, blue: 0.231, alpha: 1.0)
        Person.position = CGPoint(x: GameScene.frame.width / 2, y: GameScene.frame.height / 2 + 202)
        Person.zRotation = 3.14 / 2
        Person.zPosition = 4.0
        GameScene.addChild(Person)
        AddDot()
    }
    
    func LoadViewModern() {
        Canvas = SKSpriteNode(color: SKColor.clearColor(), size: CGSize(width: GameScene.frame.width, height: GameScene.frame.height))
        Canvas.position = CGPoint.init(x: CGRectGetMidX(GameScene.frame), y: CGRectGetMidY(GameScene.frame))
        Canvas.zPosition = 1
        GameScene.addChild(Canvas)
        
        movingClockwise = true
        loadModernElements()
        
        Circle = SKSpriteNode(imageNamed: "circle-shadow")
        Circle.size = CGSize(width: 500, height: 500)
        Circle.position = CGPoint(x: CGRectGetMidX(GameScene.frame), y: CGRectGetMidY(GameScene.frame)-130)
        Circle.zPosition = 2.0
        GameScene.addChild(Circle)
        
        Person = SKShapeNode.init(rectOfSize: CGSize(width:62,height:10), cornerRadius: 5)
        Person.fillColor = SKColor.init(red: 0.803, green: 0.404, blue: 0.404, alpha: 1.0)
        Person.strokeColor = SKColor.init(red: 0.803, green: 0.404, blue: 0.404, alpha: 1.0)
        Person.position = CGPoint(x: GameScene.frame.width / 2, y: GameScene.frame.height / 2 + 72)
        Person.zRotation = 3.14 / 2
        Person.zPosition = 2.0
        GameScene.addChild(Person)
        AddDot()
    }
    
    func LoadView(reset: Bool = false) {
        if colors.count == 0 {
            self.colors.append(UIColor(red: CGFloat(Double(207.0/255.0)), green: CGFloat(Double(240.0/255.0)), blue: CGFloat(Double(158.0/255.0)), alpha: 1.00))
            self.colors.append(UIColor(red: CGFloat(Double(168.0/255.0)), green: CGFloat(Double(219.0/255.0)), blue: CGFloat(Double(168.0/255.0)), alpha: 1.00))
            self.colors.append(UIColor(red: CGFloat(Double(100.0/255.0)), green: CGFloat(Double(223.0/255.0)), blue: CGFloat(Double(216.0/255.0)), alpha: 1.00))
            self.colors.append(UIColor(red: CGFloat(Double(227.0/255.0)), green: CGFloat(Double(158.0/255.0)), blue: CGFloat(Double(176.0/255.0)), alpha: 1.00))
            self.colors.append(UIColor(red: CGFloat(Double(78.0/255.0)), green: CGFloat(Double(125.0/255.0)), blue: CGFloat(Double(44.0/255.0)), alpha: 1.00))
            self.colors.append(UIColor(red: CGFloat(Double(181.0/255.0)), green: CGFloat(Double(217.0/255.0)), blue: CGFloat(Double(24.0/255.0)), alpha: 1.00))
            self.colors.append(UIColor(red: CGFloat(Double(6.0/255.0)), green: CGFloat(Double(176.0/255.0)), blue: CGFloat(Double(223.0/255.0)), alpha: 1.00))
            self.colors.append(UIColor(red: CGFloat(Double(147.0/255.0)), green: CGFloat(Double(155.0/255.0)), blue: CGFloat(Double(197.0/255.0)), alpha: 1.00))
            currentColorIndex = Int(floor(Double(currentLevel/10)))
            if currentColorIndex == colors.endIndex
            {
                currentColorIndex = 0
            }
            currentColor = colors[currentColorIndex]
        }
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: gameMode.rawValue + "Played")
        currentGameMode = NSUserDefaults.standardUserDefaults().stringForKey("currentGameMode")!
        scoreHolder = UIStackView()
        scoreHolder.alignment = UIStackViewAlignment.Fill
        scoreHolder.axis = UILayoutConstraintAxis.Horizontal
        scoreHolder.center = CGPoint(x: CGRectGetMidX(GameScene.frame),y: CGRectGetMidY(GameScene.frame)+200)
        scoreHolder.autoresizingMask = UIViewAutoresizing.FlexibleWidth
        scoreHolder.distribution = UIStackViewDistribution.Fill
        scoreHolder.contentMode = UIViewContentMode.ScaleToFill
        scoreHolder.semanticContentAttribute = UISemanticContentAttribute.Unspecified
        scoreHolder.translatesAutoresizingMaskIntoConstraints = false
        scoreHolder.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.0)
        GameScene.view?.addSubview(scoreHolder)
        switch gameMode
        {
        case GameModes.HardcoreModern, GameModes.ModernEndless, GameModes.Modern:
            GameScene.view?.addConstraint(NSLayoutConstraint.init(item: self.scoreHolder, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self.GameScene.view, attribute: NSLayoutAttribute.CenterX, multiplier: CGFloat(1),constant: CGFloat(0)))
            GameScene.view?.addConstraint(NSLayoutConstraint.init(item: self.scoreHolder, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: self.GameScene.view, attribute: NSLayoutAttribute.CenterY, multiplier: CGFloat(1),constant: CGFloat(130)))
            LoadViewModern()
        case GameModes.ClassicEndless, GameModes.Classic, GameModes.HardcoreClassic:
            GameScene.view?.addConstraint(NSLayoutConstraint.init(item: self.scoreHolder, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self.GameScene.view, attribute: NSLayoutAttribute.CenterX, multiplier: CGFloat(1),constant: CGFloat(0)))
            GameScene.view?.addConstraint(NSLayoutConstraint.init(item: self.scoreHolder, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: self.GameScene.view, attribute: NSLayoutAttribute.CenterY, multiplier: CGFloat(1),constant: CGFloat(0)))
            LoadViewClassic()
        }
        
        CreateDigits()
        UpdateDigits()
        
        if gameMode == .Modern || gameMode == .Classic || gameMode == .HardcoreClassic || gameMode == .HardcoreModern
        {
            LevelLabel = UILabel(frame: CGRect(x:40,y:40,width: 600,height:100))
            LevelLabel.text = "Level: \(currentLevel)"
            LevelLabel.textColor = UIColor.whiteColor()
            LevelLabel.font = UIFont.systemFontOfSize(60)
            GameScene.view?.addSubview(LevelLabel)
        }
        
        if gameMode == .ModernEndless || gameMode == .ClassicEndless || gameMode == .HardcoreClassic || gameMode == .HardcoreModern
        {
            HighscoreLabel = UILabel(frame: CGRect(x: 0, y: 40, width: 1920, height: 100))
            HighscoreLabel.text = "Highscore: \(NSUserDefaults.standardUserDefaults().integerForKey(gameMode.rawValue + "Highscore"))"
            HighscoreLabel.textColor = UIColor.whiteColor()
            HighscoreLabel.textAlignment = NSTextAlignment.Center
            HighscoreLabel.font = UIFont.systemFontOfSize(60)
            GameScene.view?.addSubview(HighscoreLabel)
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(GameHelper.selectTapped(_:)))
        tap.allowedPressTypes = [NSNumber(integer: UIPressType.Select.rawValue)]
        GameScene.view!.addGestureRecognizer(tap)
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(GameHelper.playPauseTapped(_:)))
        tap2.allowedPressTypes = [NSNumber(integer: UIPressType.PlayPause.rawValue)]
        GameScene.view!.addGestureRecognizer(tap2)
        if !reset
        {
            ColorizeCanvas()
        }
    }
    
    func SetDigitProperties(control : NumberMorphView) -> NumberMorphView {
        control.lineWidth = 12
        control.fontSize = 120
        control.animateToDigit(2)
        control.currentDigit = 0
        control.interpolator = NumberMorphView.BounceInterpolator()
        control.fontColor = UIColor.whiteColor()
        return control
    }
    
    func CreateDigits() {
        FirstDigit.SetProperties((gameMode == .Classic || gameMode == .ClassicEndless || gameMode == .HardcoreClassic) ? UIColor.whiteColor() : UIColor.whiteColor())
        SecondDigit.SetProperties((gameMode == .Classic || gameMode == .ClassicEndless || gameMode == .HardcoreClassic) ? UIColor.whiteColor() : UIColor.whiteColor())
        ThirdDigit.SetProperties((gameMode == .Classic || gameMode == .ClassicEndless || gameMode == .HardcoreClassic) ? UIColor.whiteColor() : UIColor.whiteColor())
        scoreHolder.addArrangedSubview(FirstDigit)
        scoreHolder.addArrangedSubview(SecondDigit)
        scoreHolder.addArrangedSubview(ThirdDigit)
    }
    
    func UpdateDigits() {
        let digits = String(currentScore).characters.flatMap { Int(String($0)) }
        var iteration = 0
        if gameMode == GameModes.ClassicEndless || gameMode == GameModes.ModernEndless
        {
            if NSUserDefaults.standardUserDefaults().integerForKey(gameMode.rawValue + "Highscore") < self.currentScore {
                NSUserDefaults.standardUserDefaults().setInteger(self.currentScore, forKey: gameMode.rawValue + "Highscore")
                HighscoreLabel.text = "Highscore: \(self.currentScore)"
                GCHelper.saveHighScore(self.currentScore, leaderboardId: (gameMode == .ModernEndless) ? Leaderboards.ModernEndless : Leaderboards.ClassicEndless)
            }
            if digits.count == 2 {
                scoreHolder.addArrangedSubview(SecondDigit)
            }
            else if digits.count == 3
            {
                scoreHolder.addArrangedSubview(ThirdDigit)
            }
        }
        if digits.count == 1 {
            SecondDigit.removeFromSuperview()
            ThirdDigit.removeFromSuperview()
        } else if digits.count == 2 {
            ThirdDigit.removeFromSuperview()
        }
        for digit in digits {
            if(iteration == 0)
            {
                FirstDigit.animateToDigit(digit)
            }
            else if iteration == 1
            {
                SecondDigit.animateToDigit(digit)
            }
            else if iteration == 3
            {
                ThirdDigit.animateToDigit(digit)
            }
            iteration += 1
        }
    }
    
    func loadModernElements() {
        PauseOverlay = SKSpriteNode(imageNamed: "PauseOverlay")
        PauseOverlay.size = CGSize(width: GameScene.frame.width,height: GameScene.frame.height)
        PauseOverlay.position = CGPoint.init(x: CGRectGetMidX(GameScene.frame), y: CGRectGetMidY(GameScene.frame))
        PauseOverlay.alpha = 0.0
        PauseOverlay.zPosition = 100.0
        GameScene.addChild(PauseOverlay)
        
        Dial = SKSpriteNode(imageNamed: "Dial")
        Dial.size = CGSize(width: 300, height: 300)
        Dial.position = CGPoint(x: 0, y: 0-130)
        Dial.zPosition = 5.0
        Canvas.addChild(Dial)
        
        Digits = SKSpriteNode(imageNamed: "Digits")
        Digits.size = CGSize(width: 500,height:500)
        Digits.position = CGPoint(x: 0, y: 0-130)
        Digits.zPosition = 3.0
        Canvas.addChild(Digits)
        
        Outer = SKSpriteNode(imageNamed: "Outer")
        Outer.size = CGSize(width: 690,height:690)
        Outer.position = CGPoint(x: 0, y: 0-130)
        Outer.zPosition = 6.0
        Canvas.addChild(Outer)
        
        Arrow = SKSpriteNode(imageNamed: "Arrow")
        Arrow.size = CGSize(width: 42,height:38)
        Arrow.position = CGPoint(x: 0, y: 300)
        Arrow.zPosition = 7.0
        Outer.addChild(Arrow)
        
        Lock = SKSpriteNode(imageNamed: "Lock")
        Lock.size = CGSize(width: 400,height: 400)
        Lock.position = CGPoint(x: 0, y: 0+194)
        Lock.zPosition = 2.0
        Canvas.addChild(Lock)
    }
    
    func AddDotModern() {
        Range = SKSpriteNode(imageNamed: "Range")
        Range.size = CGSize(width: 130, height: 104)
        Range.zPosition = 5.0
        
        let dx = Person.position.x - GameScene.frame.width / 2
        let dy = Person.position.y - GameScene.frame.height / 2
        
        let rad = atan2(dy, dx)
        
        if movingClockwise == true{
            var angles = calculateAngles(rad, clockwise: true)
            while CGFloat(angles[1]) <= CGFloat(0.261799)
            {
                angles = calculateAngles(rad, clockwise: true)
            }
            Range.position = CGPoint(x: 0,y:196)
            Circle.zRotation = angles[1]
        }
        else if movingClockwise == false{
            var angles = calculateAngles(rad, clockwise: false)
            while CGFloat(angles[1]) <= CGFloat(0.261799)
            {
                angles = calculateAngles(rad, clockwise: false)
            }
            Range.position = CGPoint(x: 0,y:198)
            Circle.zRotation = angles[1]
        }
        self.Circle.addChild(self.Range)
    }
    
    func AddDotClassic() {
        Dot = SKShapeNode(circleOfRadius: 30)
        Dot.antialiased = true
        Dot.fillColor =  SKColor.init(red: 0.909, green: 0.901, blue: 0.137, alpha: 1.0)
        Dot.strokeColor = SKColor.init(red: 0.909, green: 0.901, blue: 0.137, alpha: 1.0)
        Dot.zPosition = 3.0
        
        let dx = Person.position.x - GameScene.frame.width / 2
        let dy = Person.position.y - GameScene.frame.height / 2
        
        let rad = atan2(dy, dx)
        
        if movingClockwise == true{
            let tempAngle = CGFloat.Random(min: rad - 1.0, max: rad - 2.5)
            let Path2 = UIBezierPath(arcCenter: CGPoint(x: GameScene.frame.width / 2, y: GameScene.frame.height / 2), radius: 202, startAngle: tempAngle, endAngle: tempAngle + CGFloat(M_PI * 4), clockwise: true)
            Dot.position = Path2.currentPoint
            
        }
        else if movingClockwise == false{
            let tempAngle = CGFloat.Random(min: rad + 1.0, max: rad + 2.5)
            let Path2 = UIBezierPath(arcCenter: CGPoint(x: GameScene.frame.width / 2, y: GameScene.frame.height / 2), radius: 202, startAngle: tempAngle, endAngle: tempAngle + CGFloat(M_PI * 4), clockwise: true)
            Dot.position = Path2.currentPoint
            
            
        }
        GameScene.addChild(Dot)
    }
    
    func AddDot()
    {
        switch gameMode
        {
        case .Classic, .ClassicEndless, .HardcoreClassic:
            AddDotClassic()
        case .Modern, .ModernEndless, .HardcoreModern:
            AddDotModern()
        }
    }
    func calculateAngles(rad: CGFloat,clockwise: Bool) -> [CGFloat]
    {
        var tempAngle = CGFloat()
        if clockwise == true {
            tempAngle = CGFloat.Random(min: rad - 1.0, max: rad + 3.5)
        }
        else if clockwise == false
        {
            tempAngle = CGFloat.Random(min: rad + 1.0, max: rad + 3.5)
        }
        let endAngle = tempAngle + CGFloat(M_PI*4)
        var angles = [CGFloat]()
        angles.append(tempAngle);
        angles.append(endAngle);
        return angles
    }
    func ClearActions() {
        self.Circle.removeAllActions()
        self.Digits.removeAllActions()
        self.Dial.removeAllActions()
    }
    
    func StartActions(reversed: Bool)
    {
        ClearActions()
        var duration = 3.0-(floor(Double(currentLevel/10))/2)
        if duration < 2.0
        {
            duration = 2.0
        }
        let rotate = SKAction.rotateByAngle(CGFloat(M_PI*2), duration: duration)
        var repeatAction = SKAction.repeatActionForever(rotate)
        repeatAction = reversed ? repeatAction.reversedAction() : repeatAction
        self.Circle.runAction(repeatAction)
        self.Digits.runAction(repeatAction)
        self.Dial.runAction(repeatAction)
    }
    
    func moveClockWiseClassic(){
        
        let dx = Person.position.x - GameScene.frame.width / 2
        let dy = Person.position.y - GameScene.frame.height / 2
        
        let rad = atan2(dy, dx)
        
        Path = UIBezierPath(arcCenter: CGPoint(x: GameScene.frame.width / 2, y: GameScene.frame.height / 2), radius: 202, startAngle: rad, endAngle: rad + CGFloat(M_PI * 4), clockwise: true)
        let follow = SKAction.followPath(Path.CGPath, asOffset: false, orientToPath: true, speed: gameSpeed)
        Person.runAction(SKAction.repeatActionForever(follow).reversedAction())
    }
    
    func moveCounterClockWiseClassic()
    {
        let dx = Person.position.x - GameScene.frame.width / 2
        let dy = Person.position.y - GameScene.frame.height / 2
        
        let rad = atan2(dy, dx)
        
        Path = UIBezierPath(arcCenter: CGPoint(x: GameScene.frame.width / 2, y: GameScene.frame.height / 2), radius: 202, startAngle: rad, endAngle: rad + CGFloat(M_PI * 4), clockwise: true)
        let follow = SKAction.followPath(Path.CGPath, asOffset: false, orientToPath: true, speed: gameSpeed)
        Person.runAction(SKAction.repeatActionForever(follow))
    }
    
    func moveCounterClockWiseModern() {
        StartActions(true)
    }
    
    func moveClockWiseModern() {
        StartActions(false)
    }
    
    func moveClockWise()
    {
        switch gameMode
        {
        case .Classic, .ClassicEndless, .HardcoreClassic:
            moveClockWiseClassic()
        case .Modern, .ModernEndless,.HardcoreModern:
            moveClockWiseModern()
        }
    }
    
    func moveCounterClockWise(){
        switch gameMode
        {
        case .Classic, .ClassicEndless, .HardcoreClassic:
            moveCounterClockWiseClassic()
        case .Modern, .ModernEndless,.HardcoreModern:
            moveCounterClockWiseModern()
        }
    }
    @objc func playPauseTapped(gesture: UITapGestureRecognizer) {
        if !gameStarted {
            return
        }
        if gamePaused == false
        {
            if gameMode == .ModernEndless || gameMode == .Modern || gameMode == .HardcoreModern
            {
                ClearActions()
            }
            Person.paused = true
            scoreHolder.alpha = 0.0
            let fadeInAction = SKAction.fadeInWithDuration(0.5)
            PauseOverlay.runAction(fadeInAction)
        }
        else if gamePaused == true
        {
            let fadeOutAction = SKAction.fadeOutWithDuration(0.5)
            PauseOverlay.runAction(fadeOutAction,completion: {
                if self.gameMode == .ModernEndless || self.gameMode == .Modern || self.gameMode == .HardcoreModern
                {
                    self.StartActions(!self.movingClockwise)
                }
                self.scoreHolder.alpha = 1.0
                self.Person.paused = false
            })
        }
        gamePaused = !gamePaused
    }
    
    @objc func selectTapped(gesture: UITapGestureRecognizer) {
        if gameStarted == false{
            moveClockWise()
            movingClockwise = true
            gameStarted = true
        }
        else if gameStarted == true{
            numberOfClicks += 1
            if movingClockwise == true{
                
                moveCounterClockWise()
                movingClockwise = false
            }
            else if movingClockwise == false{
                
                moveClockWise()
                movingClockwise = true
            }
            DotTouched()
        }
    }
    
    
    
    
    
    func DotTouched(){
        if (gameMode == .ClassicEndless || gameMode == .ModernEndless) && totalClicks > 30
        {
            self.totalClicks = 0
            self.ColorizeCanvas()
        }
        self.totalClicks += 1
        if intersected == true{
            let soundAction = SKAction.playSoundFileNamed("collect.wav", waitForCompletion: false)
            self.GameScene.runAction(soundAction)
            Dot.removeFromParent()
            Range.removeFromParent()
            intersected = false
            if gameMode == GameModes.ClassicEndless || gameMode == GameModes.ModernEndless
            {
                currentScore += 1
            }
            else
            {
                currentScore -= 1
            }
            UpdateDigits()
            if currentScore <= 0{
                ClearActions()
                nextLevel()
            } else {
                AddDot()
            }
        }
        else if intersected == false{
            died()
        }
    }
    
    func nextLevel(){
        currentLevel += 1
        if currentLevel % 10 == 0 {
            ColorizeCanvas()
        }
        gameSpeed = CGFloat(400+(currentLevel*2))
        if(gameSpeed > 600)
        {
            gameSpeed = 600
        }
        currentScore = currentLevel
        won()
        
        // If the current level is larger than the highscore
        if currentLevel > highLevel{
            // Update highLevel
            highLevel = currentLevel
            let Defaults = NSUserDefaults.standardUserDefaults()
            Defaults.setInteger(highLevel, forKey: gameMode.rawValue + "Highscore")
            
            // Submit to leaderboard
            switch gameMode
            {
            case GameModes.Modern:
                GCHelper.saveHighScore(highLevel, leaderboardId: Leaderboards.Modern)
            case GameModes.HardcoreModern:
                GCHelper.saveHighScore(highLevel, leaderboardId: Leaderboards.ModernHardcore)
            case GameModes.Classic:
                GCHelper.saveHighScore(highLevel, leaderboardId: Leaderboards.Classic)
            case GameModes.HardcoreClassic:
                GCHelper.saveHighScore(highLevel, leaderboardId: Leaderboards.ClassicHardcore)
            case GameModes.ClassicEndless:
                GCHelper.saveHighScore(highLevel, leaderboardId: Leaderboards.ClassicEndless)
            case GameModes.ModernEndless:
                GCHelper.saveHighScore(highLevel, leaderboardId: Leaderboards.ModernEndless)
            }
            GCHelper.StoreAchievement(AchievementHelper.TenLocksAchievementID, number: highLevel, goal: 10)
            GCHelper.StoreAchievement(AchievementHelper.TwentyFiveLocksAchievementID, number: highLevel, goal: 25)
            GCHelper.StoreAchievement(AchievementHelper.FiftyLocksAchievementID, number: highLevel, goal: 50)
        }
    }
    
    func diedClassic() {
        GameScene.removeAllChildren()
        intersected = false
        gameStarted = false
        currentScore = currentLevel
        self.LoadView(true)
    }
    
    func diedModern() {
        Range.removeFromParent()
        ClearActions()
        self.intersected = false
        self.gameStarted = false
        let shakeAction = SKAction.shake(Canvas.position, duration: 2)
        Canvas.runAction(shakeAction,completion: {
            self.scoreHolder.removeFromSuperview()
            self.GameScene.removeAllChildren()
            self.currentScore = self.currentLevel
            self.LoadView(true)
        })
    }
    
    func died(){
        if ALInterstitialAd.isReadyForDisplay() && (deaths >= 5 || numberOfClicks >= 100) && NSUserDefaults.standardUserDefaults().boolForKey("removedAds") == false
        {
            deaths = 0
            numberOfClicks = 0
            ShowAd()
        }
        else
        {
            deaths += 1
        }
        self.HighscoreLabel.removeFromSuperview()
        self.LevelLabel.removeFromSuperview()
        let currentHigh = NSUserDefaults.standardUserDefaults().integerForKey(gameMode.rawValue + "Highscore")
        if currentScore > currentHigh
        {
            switch gameMode
            {
            case .Classic:
                GCHelper.saveHighScore(currentScore, leaderboardId: Leaderboards.Classic)
            case .ClassicEndless:
                GCHelper.saveHighScore(currentScore, leaderboardId: Leaderboards.ClassicEndless)
            case .HardcoreClassic:
                GCHelper.saveHighScore(currentScore, leaderboardId: Leaderboards.ClassicHardcore)
            case .HardcoreModern:
                GCHelper.saveHighScore(currentScore, leaderboardId: Leaderboards.ModernHardcore)
            case .Modern:
                GCHelper.saveHighScore(currentScore, leaderboardId: Leaderboards.Modern)
            case .ModernEndless:
                GCHelper.saveHighScore(currentScore, leaderboardId: Leaderboards.ModernEndless)
            }
            NSUserDefaults.standardUserDefaults().setInteger(currentScore, forKey: gameMode.rawValue + "Highscore")
        }
        if(self.gameMode == GameModes.HardcoreClassic || self.gameMode == GameModes.HardcoreModern)
        {
            
            // Set currentlevel and currentscore to 1
            self.currentLevel = 1
            self.currentScore = 1
        }
        let soundAction = SKAction.playSoundFileNamed("FAIL.wav", waitForCompletion: false)
        self.GameScene.runAction(soundAction)
        switch gameMode {
        case .ModernEndless, .Modern, .HardcoreModern:
            diedModern()
        case .ClassicEndless, .Classic, .HardcoreClassic:
            diedClassic()
        }
    }
    func wonClassic(){
        GameScene.removeAllChildren()
        intersected = false
        gameStarted = false
        self.scoreHolder.removeFromSuperview()
        self.LoadView(true)
    }
    
    func wonModern() {
        let lockAction = SKAction.moveByX(0, y: 120, duration: 1.0)
        Lock.runAction(lockAction, completion: {
            self.Lock.runAction(lockAction.reversedAction(),completion: {
                self.scoreHolder.removeFromSuperview()
                self.GameScene.removeAllChildren()
                self.intersected = false
                self.gameStarted = false
                self.LoadView(true)
            })
        })
    }
    
    func won(){
        self.LevelLabel.removeFromSuperview()
        self.HighscoreLabel.removeFromSuperview()
        let soundAction = SKAction.playSoundFileNamed("winning.wav", waitForCompletion: false)
        self.GameScene.runAction(soundAction)
        if ALInterstitialAd.isReadyForDisplay() && (numberOfClicks >= 100 || deaths >= 5) && NSUserDefaults.standardUserDefaults().boolForKey("removedAds") == false
        {
            numberOfClicks = 0
            deaths = 0
            ShowAd()
        }
        switch gameMode
        {
        case .Classic, .ClassicEndless, .HardcoreClassic:
            wonClassic()
        case .Modern, .ModernEndless, .HardcoreModern:
            wonModern()
        }
    }
}
