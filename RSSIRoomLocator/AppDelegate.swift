//
//  AppDelegate.swift
//  RSSIRoomLocator
//
//  Created by Tyler Casselman on 3/29/15.
//  Copyright (c) 2015 Casselman Consulting. All rights reserved.
//

import UIKit
import CocoaLumberjack

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        DDLog.addLogger(DDTTYLogger.sharedInstance())
        defaultDebugLevel = DDLogLevel.Verbose
        return true
    }
    
}

