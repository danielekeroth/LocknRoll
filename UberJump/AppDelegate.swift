//
//  AppDelegate.swift
//  UberJump
//
//  Created by Daniel Ekeroth on 2016-04-18.
//  Copyright © 2016 Geekfox Consulting. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics
import Answers

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        ALSdk.initializeSdk()
        // Override point for customization after application launch.
        Global.BackgroundMusic.append(Sound(path: "circus.mp3",name: "Circus"))
        Global.BackgroundMusic.append(Sound(path: "space.mp3",name: "Space"))
        Global.BackgroundMusic.append(Sound(path: "endless.mp3",name: "Endless"))
        Global.BackgroundMusic.append(Sound(path: "bgmusic.mp3",name: "Default"))
        Fabric.with([Answers.self, Crashlytics.self])
        Answers.logCustomEventWithName("Started App", customAttributes: nil)
        return true
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        Answers.logCustomEventWithName("Entered Background", customAttributes: nil)
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        Answers.logCustomEventWithName("Resumed App", customAttributes: nil)
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        Answers.logCustomEventWithName("Closed App", customAttributes: nil)
    }
    
    func application(app: UIApplication, openURL url: NSURL, options: [String : AnyObject]) -> Bool {
        
        if url.host == nil
        {	return true
        }
        
        let urlString = url.absoluteString
        let queryArray = urlString.componentsSeparatedByString("/")
        let query = queryArray[2]
        if query.rangeOfString("classicHardcore") != nil
        {
            
        }
        else if query.rangeOfString("classic") != nil
        {
            
        }
        else if query.rangeOfString("modernHardcore") != nil
        {
            
        }
        else if query.rangeOfString("modern") != nil
        {
            
        }
        
        return true
    }
}

