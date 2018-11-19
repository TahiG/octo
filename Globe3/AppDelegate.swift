//
//  AppDelegate.swift
//  Globe3
//
//  Created by Charles Masson on 10/10/15.
//  Copyright (c) 2015 Charles Masson. All rights reserved.
//

import UIKit
import Parse
import FBSDKCoreKit
import ParseFacebookUtilsV4
import GoogleMaps
import FolioReaderKit

        
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        // [Optional] Power your app with Local Datastore. For more info, go to
        // https://parse.com/docs/ios_guide#localdatastore/iOS
        Parse.enableLocalDatastore()
        
        // Initialize Parse
        let kPARSE_APPID = "6ksnW4ymmW9LnK6lZkBP080Lv6FlPAnkZtRaLwVH"
        let kPARSE_CLIENTKEY = "VMdF6n9uD0meLiu8taZzNzDjCE9vWnN3kl4iyyuT"
        let kPARSE_SERVERURL = "https://getglobe.herokuapp.com/parse"
        let S3_ACCESS_KEY = "AKIAJFDF5VYGCW4WDBLQ"
        let S3_SECRET_KEY = "sKfkDccLnezIXtUoBShgZPNLiXNHgYHL7"
        
        let configuration = ParseClientConfiguration {
            $0.applicationId = kPARSE_APPID
            $0.clientKey = kPARSE_CLIENTKEY
            $0.server = kPARSE_SERVERURL
        }
        
        Parse.initializeWithConfiguration(configuration)
        
        //Parse.setApplicationId("6ksnW4ymmW9LnK6lZkBP080Lv6FlPAnkZtRaLwVH",
            //clientKey: "VMdF6n9uD0meLiu8taZzNzDjCE9vWnN3kl4iyyuT")
        
        PFFacebookUtils.initializeFacebookWithApplicationLaunchOptions(launchOptions)

        // [Optional] Track statistics around application opens.
        PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
        
        GMSServices.provideAPIKey("AIzaSyDiupgA36TDv6lvds7aJjLZ-AZp7O8LsfU")

        /*FTGooglePlacesAPIService.provideAPIKey("AIzaSyDiupgA36TDv6lvds7aJjLZ-AZp7O8LsfU")
        FTGooglePlacesAPIService.setDebugLoggingEnabled(true)*/
        
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        FolioReader.applicationWillResignActive()
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
        FBSDKAppEvents.activateApp()
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        FolioReader.applicationWillTerminate()
    }


}

