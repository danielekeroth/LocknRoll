//
//  GameViewController.swift
//  UberJump
//
//  Created by Daniel Ekeroth on 2016-04-18.
//  Copyright (c) 2016 Geekfox Consulting. All rights reserved.
//

import UIKit
import SpriteKit
import StoreKit
import GameKit
import Crashlytics
import Answers
import AVKit
import MediaPlayer


class GameViewController: UIViewController,SKPaymentTransactionObserver,SKProductsRequestDelegate {
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var startGameButton: UIButton!
    @IBOutlet weak var gcButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var removeAdsButton: UIButton!
    @IBOutlet weak var muteButton: UIButton!
    @IBAction func removeAdsButton(sender: AnyObject) {
        for product in products {
            let prodID = product.productIdentifier
            if(prodID == "com.geekfox.locknroll.removeads")
            {
                p = product
                buyProduct()
                break;
            }
        }
    }
    @IBAction func toggleMute(sender: UIButton) {
        Global.toggleMute(sender)
    }
    
    var products = [SKProduct]()
    var p = SKProduct()
    private var productsRequest: SKProductsRequest?
    
    override var preferredFocusedView: UIView? {
        get {
            return self.startGameButton
        }
    }
    
    func buyProduct() {
        Answers.logCustomEventWithName("Purchase started", customAttributes: ["Product":p.productIdentifier,"Price":p.price])
        let pay = SKPayment(product: p)
        SKPaymentQueue.defaultQueue().addTransactionObserver(self)
        SKPaymentQueue.defaultQueue().addPayment(pay as SKPayment)
    }
    
    var appStoreAvailable = false
    
    func productsRequest(request: SKProductsRequest,didReceiveResponse response: SKProductsResponse)
    {
        let myProducts = response.products
        if myProducts.count > 0
        {
            //removeAdsButton.alpha = 1.0
            //removeAdsButton.enabled = true
            appStoreAvailable = true
        }
        for product in myProducts
        {
            products.append(product as SKProduct)
        }
    }
    
    func paymentQueue(queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions
        {
            let trans = transaction as SKPaymentTransaction
            print(trans.error)
            switch trans.transactionState {
            case .Purchased:
                let eventService = ALSdk.shared()
                eventService?.eventService.trackInAppPurchaseWithTransactionIdentifier(trans.transactionIdentifier!, parameters:
                    [kALEventParameterStoreKitTransactionIdentifierKey:trans.transactionIdentifier!,
                        kALEventParameterRevenueAmountKey:p.price,
                        kALEventParameterRevenueCurrencyKey:p.priceLocale]
                )
                Answers.logCustomEventWithName("Purchase completed", customAttributes: ["Product":p.productIdentifier,"Price":p.price])
                queue.finishTransaction(trans)
                removeAds()
                break
            case .Failed:
                let alert = UIAlertController.init(title: trans.error!.localizedDescription, message: "Please try again", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction.init(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
                Answers.logCustomEventWithName("Purchase failed", customAttributes: ["Reasion":trans.error!.localizedDescription])
                queue.finishTransaction(trans)
                break
            case .Restored:
                removeAds()
            default:
                break
            }
        }
    }
    
    func paymentQueue(queue: SKPaymentQueue, removedTransactions transactions: [SKPaymentTransaction]) {
        
    }
    
    func finishTransaction(trans:SKPaymentTransaction)
    {
    }
    
    func restorePurchases(sender: UIButton)
    {
        SKPaymentQueue.defaultQueue().addTransactionObserver(self)
        SKPaymentQueue.defaultQueue().restoreCompletedTransactions()
    }
    
    func removeAds() {
        // Add logic to set ads removed to true
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "removedAds")
        //removeAdsButton.enabled = false
        //removeAdsButton.alpha = 0.0
        let alert = UIAlertController.init(title: "Ads has been removed.", message: "", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction.init(title: "Close", style: UIAlertActionStyle.Cancel, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func paymentQueue(queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: NSError) {
        for transaction in queue.transactions
        {
            let t:SKPaymentTransaction = transaction as SKPaymentTransaction
            _ = t
        }
    }
    
    func initializeMainMenu() {
        if(NSUserDefaults.standardUserDefaults().boolForKey("removedAds") || products.count == 0)
        {
            //removeAdsButton.enabled = false
            //removeAdsButton.alpha = 0.0
        }
        //Global.checkMute(muteButton)
        if(BGMusic == nil)
        {
            var volume = NSUserDefaults.standardUserDefaults().floatForKey("Volume")
            let isMuted = NSUserDefaults.standardUserDefaults().boolForKey("isMuted")
            if(volume == 0 && !isMuted)
            {
                volume = 1.0
            }
            
            let song = Global.BackgroundMusic.filter{$0.Name == NSUserDefaults.standardUserDefaults().stringForKey("backgroundMusic")!}.first!
            BGMusic = AudioPlayer(path: song.Path,autoPlay: true,repeatForever: true,volume: volume,name: song.Name)
        }
    }
    
    func registerDefaults() {
        NSUserDefaults.standardUserDefaults().registerDefaults(["backgroundMusic":"Default","volume":Float(1.0),"currentGameMode":"Normal"])
    }
    @IBAction func callGC(sender: AnyObject) {
        GCHelper.showLeaderboard(self)
    }
    
    var contentURL = NSBundle.mainBundle().URLForResource("intro", withExtension: "mp4")
    var IntroPlayer = AVPlayer()
    var playerView = UIView()
    var playerLayer = AVPlayerLayer()
    @IBOutlet weak var logoImage: UIImageView!
    
    func AddIntroVideo() {
        let playerItem = AVPlayerItem(URL: contentURL!)
        IntroPlayer = AVPlayer(playerItem: playerItem)
        playerLayer = AVPlayerLayer(player: IntroPlayer)
        playerView = UIView(frame: CGRectMake(0, 0, self.view.frame.width, self.view.frame.height))
        self.view.layer.addSublayer(playerLayer)
        playerLayer.frame = view.bounds
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(GameViewController.playerDidFinishPlaying(_:)),
                                                         name: AVPlayerItemDidPlayToEndTimeNotification, object: IntroPlayer.currentItem)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(GameViewController.playerHadError(_:)), name: AVPlayerItemNewErrorLogEntryNotification, object: IntroPlayer.currentItem)
        self.view.addSubview(playerView)
        IntroPlayer.play()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        AddIntroVideo()
    }
    
    func InitializeUI() {
        self.playerLayer.removeFromSuperlayer()
        UIView.animateWithDuration(1.2, animations: {
            if self.logoImage.center.y == self.view.center.y {
                self.logoImage.center.y -= 300
            }
            //self.muteButton.alpha = 1.0
            //self.gcButton.alpha = 1.0
            self.settingsButton.alpha = 1.0
            self.startGameButton.alpha = 1.0
            if self.appStoreAvailable {
                //self.removeAdsButton.alpha = 1.0
                //self.removeAdsButton.enabled = true
            }
            }, completion: {
                (value: Bool) in
                let verticalConstraint = self.logoImage.centerYAnchor.constraintEqualToAnchor(self.view.centerYAnchor,constant: -300)
                self.view.addConstraint(verticalConstraint)
                self.playerView.removeFromSuperview()
                self.view.setNeedsFocusUpdate()
                self.view.updateFocusIfNeeded()
                GCHelper.authPlayer(self.view)
                self.registerDefaults()
                if(self.isKindOfClass(GameViewController))
                {
                    if SKPaymentQueue.canMakePayments() {
                        self.productsRequest = SKProductsRequest(productIdentifiers: ["com.geekfox.locknroll.removeads"])
                        self.productsRequest!.delegate = self
                        self.productsRequest!.start()
                    }
                    self.initializeMainMenu()
                }
        })
    }
    
    func playerHadError(note: NSNotification) {
        InitializeUI()
        Answers.logCustomEventWithName("Intro Video Failed", customAttributes: nil)
    }
    
    override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        let nameValue = anim.valueForKey("fadeOut") as? String
        if let name = nameValue {
            if (name == "video") {
                InitializeUI()
            }
        }
    }
    
    var fadeOut:CABasicAnimation!
    
    func playerDidFinishPlaying(note: NSNotification) {
        fadeOut = CABasicAnimation(keyPath: "opacity")
        fadeOut.fromValue = 1.0
        fadeOut.toValue = 0.0
        fadeOut.duration = 1.2
        fadeOut.delegate = self
        fadeOut.setValue("video", forKey:"fadeOut")
        fadeOut.removedOnCompletion = false
        fadeOut.fillMode = kCAFillModeForwards
        playerLayer.addAnimation(fadeOut, forKey: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
}
