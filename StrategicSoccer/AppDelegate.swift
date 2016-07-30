//
//  AppDelegate.swift
//  StrategicSoccer
//
//  Created by Stephen on 6/14/16.
//  Copyright © 2016 HS. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        if let gameVC = getCurrentViewController() as? GameViewController{
            gameVC.PauseClicked(GameViewController)
            gameVC.scene.physicsWorld.speed = 0
        }
    }
    func getCurrentViewController()->UIViewController?{
        if let vc = self.window!.rootViewController as? UINavigationController{
            return vc.visibleViewController!
        }
        return nil
    }
    func applicationDidFinishLaunching(application: UIApplication) {
        ALSdk.initializeSdk()
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        
        
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        if let gameVC = getCurrentViewController() as? GameViewController{
            gameVC.PauseClicked(GameViewController)
            gameVC.scene.paused = true
        }
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

