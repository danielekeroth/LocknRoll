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

public class GameHelper : NodeCollection
{
    init(mode: GameModes){
        self.gameMode = mode
    }
    // Variables and Properties
    var gameMode : GameModes
    var DigitCollection = [NumberMorphView(),NumberMorphView(),NumberMorphView()]
    var deaths = 0
    var numberOfClicks = 0
    var intersected = false
    var Path = UIBezierPath()
    var currentLevel = Int()
    var currentScore = Int()
    var highLevel = Int()
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
        let isBlack = contrastValue/100 > 125
        HighscoreLabel.textColor = isBlack ? UIColor.blackColor() : UIColor.whiteColor()
        LevelLabel.textColor = isBlack ? UIColor.blackColor() : UIColor.whiteColor()
        for digit in DigitCollection
        {
            digit.fontColor = isBlack ? UIColor.blackColor() : UIColor.whiteColor()
        }
        let action = SKAction.colorizeWithColor(self.currentColor, colorBlendFactor: 1.0, duration: 1.2)
        self.Canvas.removeActionForKey("colorize")
        self.GameScene.runAction(action, withKey: "colorize")
    }
    
    func ShowAd() {
        self.deaths = 0
        self.numberOfClicks = 0
        let scene = self.GameScene as! GameScene
        scene.ShowAd()
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
    
    func LoadViewShared(yOffset: CGFloat)
    {
        Canvas = SKSpriteNode(color: SKColor.clearColor(), size: CGSize(width: GameScene.frame.width, height: GameScene.frame.height))
        Canvas.position = CGPoint.init(x: CGRectGetMidX(GameScene.frame), y: CGRectGetMidY(GameScene.frame))
        Canvas.zPosition = 1
        GameScene.addChild(Canvas)
        
        movingClockwise = true
        
        Circle = SKSpriteNode(imageNamed: "circle-shadow")
        Circle.size = CGSize(width: 500, height: 500)
        Circle.position = CGPoint(x: CGRectGetMidX(GameScene.frame), y: CGRectGetMidY(GameScene.frame)-yOffset)
        Circle.zPosition = 2.0
        GameScene.addChild(Circle)
    }
    
    func AddPerson(heightOffset: CGFloat, zPos: CGFloat)
    {
        Person = SKShapeNode.init(rectOfSize: CGSize(width:62,height:9), cornerRadius: 4)
        Person.fillColor = SKColor.init(red: 0.803, green: 0.404, blue: 0.404, alpha: 1.0)
        Person.strokeColor = SKColor.init(red: 0.803, green: 0.404, blue: 0.404, alpha: 1.0)
        Person.position = CGPoint(x: GameScene.frame.width / 2, y: GameScene.frame.height / 2 + heightOffset)
        Person.zRotation = 3.14 / 2
        Person.zPosition = zPos
        GameScene.addChild(Person)
    }
    
    
    func InitializeColors() {
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
    
    func AddScoreHolder() {
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
        let yOffset = (gameMode == .HardcoreModern || gameMode == .ModernEndless || gameMode == .Modern) ? 130 : 0
        GameScene.view?.addConstraint(NSLayoutConstraint.init(item: self.scoreHolder, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self.GameScene.view, attribute: NSLayoutAttribute.CenterX, multiplier: CGFloat(1),constant: CGFloat(0)))
        GameScene.view?.addConstraint(NSLayoutConstraint.init(item: self.scoreHolder, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: self.GameScene.view, attribute: NSLayoutAttribute.CenterY, multiplier: CGFloat(1),constant: CGFloat(yOffset)))
    }
    
    func AddLevelLabel() {
        LevelLabel = UILabel(frame: CGRect(x:40,y:40,width: 600,height:100))
        LevelLabel.text = "Level: \(currentLevel)"
        LevelLabel.textColor = UIColor.whiteColor()
        LevelLabel.font = UIFont.systemFontOfSize(60)
        GameScene.view?.addSubview(LevelLabel)
    }
    
    func AddHighscoreLabel() {
        HighscoreLabel = UILabel(frame: CGRect(x: 0, y: 40, width: 1920, height: 100))
        HighscoreLabel.text = "Highscore: \(NSUserDefaults.standardUserDefaults().integerForKey(gameMode.rawValue + "Highscore"))"
        HighscoreLabel.textColor = UIColor.whiteColor()
        HighscoreLabel.textAlignment = NSTextAlignment.Center
        HighscoreLabel.font = UIFont.systemFontOfSize(60)
        GameScene.view?.addSubview(HighscoreLabel)
    }
    
    
    func AddPauseOverlay() {
        PauseOverlay = SKSpriteNode(imageNamed: "PauseOverlay")
        PauseOverlay.size = CGSize(width: GameScene.frame.width,height: GameScene.frame.height)
        PauseOverlay.position = CGPoint.init(x: CGRectGetMidX(GameScene.frame), y: CGRectGetMidY(GameScene.frame))
        PauseOverlay.alpha = 0.0
        PauseOverlay.zPosition = 100.0
        GameScene.addChild(PauseOverlay)
    }
    
    var isModern = false
    
    func LoadView(reset: Bool = false) {
        if colors.count == 0 {
            InitializeColors()
        }
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: gameMode.rawValue.containsString("Classic") ? "Classic" : "Modern" + "Played")
        if NSUserDefaults.standardUserDefaults().boolForKey("ModernPlayed") == true && NSUserDefaults.standardUserDefaults().boolForKey("ClassicPlayed") == true {
            GCHelper.StoreAchievement(AchievementHelper.MixItUp)
        }
        currentGameMode = NSUserDefaults.standardUserDefaults().stringForKey("currentGameMode")!
        AddScoreHolder()
        AddPauseOverlay()
        isModern = (gameMode == .HardcoreModern || gameMode == .ModernEndless || gameMode == .Modern)
        LoadViewShared(isModern ? 130 : 0)
        AddPerson(isModern ? 72 : 202, zPos: isModern ? 2.0 : 4.0)
        if isModern { loadModernElements() }
        AddDot()
        
        CreateDigits()
        UpdateDigits()
        
        if gameMode == .Modern || gameMode == .Classic || gameMode == .HardcoreClassic || gameMode == .HardcoreModern
        {
            AddLevelLabel()
        }
        
        if gameMode == .ModernEndless || gameMode == .ClassicEndless || gameMode == .HardcoreClassic || gameMode == .HardcoreModern
        {
            AddHighscoreLabel()
        }
        
        if !reset
        {
            ColorizeCanvas()
        }
        AddTapRecognizers()
    }
    
    func AddTapRecognizers() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(GameHelper.selectTapped(_:)))
        tap.allowedPressTypes = [NSNumber(integer: UIPressType.Select.rawValue)]
        GameScene.view!.addGestureRecognizer(tap)
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(GameHelper.playPauseTapped(_:)))
        tap2.allowedPressTypes = [NSNumber(integer: UIPressType.PlayPause.rawValue)]
        GameScene.view!.addGestureRecognizer(tap2)
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
        for digit in DigitCollection
        {
            digit.SetProperties((gameMode == .Classic || gameMode == .ClassicEndless || gameMode == .HardcoreClassic) ? UIColor.whiteColor() : UIColor.whiteColor())
            scoreHolder.addArrangedSubview(digit)
        }
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
                scoreHolder.addArrangedSubview(DigitCollection[1])
            }
            else if digits.count == 3
            {
                scoreHolder.addArrangedSubview(DigitCollection[2])
            }
        }
        if digits.count == 1 {
            DigitCollection[1].removeFromSuperview()
            DigitCollection[2].removeFromSuperview()
        } else if digits.count == 2 {
            DigitCollection[2].removeFromSuperview()
        }
        for digit in digits {
            DigitCollection[iteration].animateToDigit(digit)
            iteration += 1
        }
    }
    
    func loadModernElements() {
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
        
        let rad = getRad()
        
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
        
        let rad = getRad()
        let tempAngle = movingClockwise ? CGFloat.Random(min: rad - 1.0, max: rad - 2.5) : CGFloat.Random(min: rad + 1.0, max: rad + 2.5)
        let Path2 = UIBezierPath(arcCenter: CGPoint(x: GameScene.frame.width / 2, y: GameScene.frame.height / 2), radius: 202, startAngle: tempAngle, endAngle: tempAngle + CGFloat(M_PI * 4), clockwise: true)
        Dot.position = Path2.currentPoint
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
        let tempAngle = clockwise ? CGFloat.Random(min: rad - 1.0, max: rad - 3.5) : CGFloat.Random(min: rad + 1.0, max: rad + 3.5)
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
    
    func getRad() -> CGFloat {
        return atan2(Person.position.y - GameScene.frame.height / 2, Person.position.x - GameScene.frame.width / 2)
    }
    
    func moveClassic(clockwise: Bool){
        let rad = getRad()
        let follow = SKAction.followPath((UIBezierPath(arcCenter: CGPoint(x: GameScene.frame.width / 2, y: GameScene.frame.height / 2), radius: 202, startAngle: rad, endAngle: rad + CGFloat(M_PI * 4), clockwise: true)).CGPath, asOffset: false, orientToPath: true, speed: gameSpeed)
        if clockwise { Person.runAction(SKAction.repeatActionForever(follow).reversedAction()) } else { Person.runAction(SKAction.repeatActionForever(follow)) }
    }
    
    func moveCounterClockWiseModern() {
        StartActions(true)
    }
    
    func moveClockWiseModern() {
        StartActions(false)
    }
    
    func moveClockWise()
    {
        if gameMode.rawValue.containsString("Classic") { moveClassic(true) } else { moveClockWiseModern() }
    }
    
    func moveCounterClockWise(){
        if gameMode.rawValue.containsString("Classic") { moveClassic(false) } else { moveCounterClockWiseModern() }
    }
    
    @objc func playPauseTapped(gesture: UITapGestureRecognizer)
    {
        if !gameStarted { return }
        let fadeInAction = SKAction.fadeInWithDuration(0.2)
        let fadeOutAction = SKAction.fadeOutWithDuration(0.2)
        PauseOverlay.runAction(gamePaused ? fadeInAction : fadeOutAction, completion: {
            if self.gameMode.rawValue.containsString("Modern") && self.gamePaused { self.StartActions(!self.movingClockwise) } else if self.gameMode.rawValue.containsString("Modern") && !self.gamePaused { self.ClearActions() }
            self.Person.paused = !self.gamePaused
            self.scoreHolder.alpha = self.gamePaused ? 1.0 : 0.0
        })
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
            if movingClockwise { moveCounterClockWise() } else { moveClockWise() }
            movingClockwise = !movingClockwise
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
            if gameMode == GameModes.ClassicEndless || gameMode == GameModes.ModernEndless { currentScore += 1 } else { currentScore -= 1 }
            UpdateDigits()
            if currentScore > 0 { AddDot() } else
            {
                ClearActions()
                nextLevel()
            }
        }
        else if intersected == false { died() }
    }
    
    func updateGameSpeed() {
        gameSpeed = CGFloat(400+(currentLevel*2))
        if(gameSpeed > 600)
        {
            gameSpeed = 600
        }
    }
    
    func nextLevel(){
        currentLevel += 1
        if currentLevel % 10 == 0 {
            ColorizeCanvas()
        }
        updateGameSpeed()
        currentScore = currentLevel
        won()
        // If the current level is larger than the highscore
        if currentLevel > highLevel{
            // Update highLevel
            highLevel = currentLevel
            let Defaults = NSUserDefaults.standardUserDefaults()
            Defaults.setInteger(highLevel, forKey: gameMode.rawValue + "Highscore")
            
            // Submit to leaderboard
            UpdateLeaderboards()
            GCHelper.StoreAchievement(AchievementHelper.TenLocksAchievementID, number: highLevel, goal: 10)
            GCHelper.StoreAchievement(AchievementHelper.TwentyFiveLocksAchievementID, number: highLevel, goal: 25)
            GCHelper.StoreAchievement(AchievementHelper.FiftyLocksAchievementID, number: highLevel, goal: 50)
        }
    }
    
    
    
    func UpdateLeaderboards()
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
    }
    
    func diedShared(modern: Bool) {
        totalClicks = 0
        if ALInterstitialAd.isReadyForDisplay() && (deaths >= 10 || numberOfClicks >= 100) && NSUserDefaults.standardUserDefaults().boolForKey("removedAds") == false
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
            UpdateLeaderboards()
            NSUserDefaults.standardUserDefaults().setInteger(currentScore, forKey: gameMode.rawValue + "Highscore")
        }
        if(self.gameMode == GameModes.HardcoreClassic || self.gameMode == GameModes.HardcoreModern)
        {
            self.currentLevel = 1
            self.currentScore = 1
        }
        let soundAction = SKAction.playSoundFileNamed("FAIL.wav", waitForCompletion: false)
        self.GameScene.runAction(soundAction)
        GameScene.removeAllChildren()
        intersected = false
        gameStarted = false
        if modern
        {
            let shakeAction = SKAction.shake(Canvas.position, duration: 2)
            Canvas.runAction(shakeAction,completion: {
                self.ResetView()
            })}
        else
        {
            ResetView()
        }
    }
    
    func ResetView() {
        self.scoreHolder.removeFromSuperview()
        self.GameScene.removeAllChildren()
        self.currentScore = self.currentLevel
        self.LoadView(true)
    }
    
    func diedModern() {
        ClearActions()
        diedShared(true)
    }
    
    func died(){
        switch gameMode {
        case .ModernEndless, .Modern, .HardcoreModern:
            diedModern()
        case .ClassicEndless, .Classic, .HardcoreClassic:
            diedShared(false)
        }
    }
    
    func wonShared()
    {
        self.LevelLabel.removeFromSuperview()
        self.HighscoreLabel.removeFromSuperview()
        let soundAction = SKAction.playSoundFileNamed("winning.wav", waitForCompletion: false)
        self.GameScene.runAction(soundAction)
        if ALInterstitialAd.isReadyForDisplay() && (numberOfClicks >= 100 || deaths >= 10) && NSUserDefaults.standardUserDefaults().boolForKey("removedAds") == false
        {
            numberOfClicks = 0
            deaths = 0
            ShowAd()
        }
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
                self.wonShared()
            })
        })
    }
    
    func won(){
        switch gameMode
        {
        case .Classic, .ClassicEndless, .HardcoreClassic:
            wonShared()
        case .Modern, .ModernEndless, .HardcoreModern:
            wonModern()
        }
    }
}
