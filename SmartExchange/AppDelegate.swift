//
//  AppDelegate.swift
//  SmartExchange
//
//  Created by Abhimanyu Saraswat on 15/02/17.
//  Copyright © 2017 ZeroWaste. All rights reserved.
//

import UIKit
import Firebase
//import NewRelic
import Clarity

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    var supportEmailAddress : String?
    var supportPhoneNumber : String?
    var supportChatNumber : String?
    
    var appStoreName : String?
    var appStoreAddress : String?
    var appStoreContactNumber : String?
    var appStoreLatitude : String?
    var appStoreLongitude : String?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        //NewRelic.start(withApplicationToken: "eu01xxee4e481a844aeccafaee48fd3c22408575fc-NRMA")
        
        // Note: Set ".verbose" value for "logLevel" parameter while testing to debug initialization issues.
        let clarityConfig = ClarityConfig(projectId: "q41zzaqht8")
        ClaritySDK.initialize(config: clarityConfig)
        
        // Override point for customization after application launch.
        FirebaseApp.configure()
        
        //sleep(UInt32(1.0))
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        
        if let detect = detectScreenshot {
            detect()
        }
        
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func navIntoApp() {
        
        // Create the root view controller
        let mainStoryBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let rootViewController = mainStoryBoard.instantiateViewController(withIdentifier: "LaunchScreenVC") as! LaunchScreenVC
        
        // Embed it in a UINavigationController
        let navigationController = UINavigationController(rootViewController: rootViewController)
        
        // Set up the window
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        self.window = window
        
    }
    
}
