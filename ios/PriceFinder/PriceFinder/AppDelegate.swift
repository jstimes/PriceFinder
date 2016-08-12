 
//
//  AppDelegate.swift
//  PriceFinder
//
//  Created by jacob stimes on 5/22/16.
//  Copyright © 2016 stimes.enterprises. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

	///Authorizes notifications and sets up app to run a background fetch in 24 hours
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        let notificationSettings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil);
        UIApplication.sharedApplication().registerUserNotificationSettings(notificationSettings);
        
        guard let settings = UIApplication.sharedApplication().currentUserNotificationSettings() else { return true;
        }
        
        if settings.types != .None {
            let secondsPerDay: NSTimeInterval = 86400; 
            UIApplication.sharedApplication().setMinimumBackgroundFetchInterval(
                secondsPerDay);
        }
        
        return true;
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
	/// Trigger background fetch to update user's saved item prices. Notifies them if an item has a price below their set target price
    func application(application: UIApplication, performFetchWithCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        
        SearchRunner.backgroundFetch {
            completionHandler(.NewData);
        }
    }

}

