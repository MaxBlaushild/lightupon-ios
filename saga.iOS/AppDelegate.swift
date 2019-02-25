//
//  AppDelegate.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 1/30/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//

import UIKit
import GoogleMaps
import FBSDKLoginKit
import UserNotifications
import TwitterKit
import Foundation

let googleMapsApiKey = "AIzaSyBS-y6hKLFKiM5yUWIO0AYR5-lrkCZSvp0"
let twitterKey = "Tbo4foIOQNU4UguU7L2TvqwvF"
let twitterSecret = "n64QcM5iksN6imlzdAYRVVEqFMpFtXT2HdftyYLZbsXPlmyTlt"
let instagramClientId = "d0f146b43a394fb3b5334da7cbb3f053"

class DeepLink {
    let resource: String
    let id: Int
    
    init(resource: String, id: Int) {
        self.resource = resource
        self.id = id
    }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var loadedEnoughToDeepLink:Bool = false
    var deepLink: DeepLink?
    var backgroundLocationManager = BackgroundLocationManager()
    var apiAmbassador: AmbassadorToTheAPI!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        GMSServices.provideAPIKey(googleMapsApiKey)
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        FBSDKLoginManager.renewSystemCredentials { (result:ACAccountCredentialRenewResult, error:Error?) -> Void in

        }
        
        TWTRTwitter.sharedInstance().start(withConsumerKey: twitterKey, consumerSecret: twitterSecret)
        
        let authService = AuthService()
        apiAmbassador = AmbassadorToTheAPI(authService: authService)
        
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        var token = ""
        for i in 0..<deviceToken.count {
            token = token + String(format: "%02.2hhx", arguments: [deviceToken[i]])
        }
        
        let parameters = [
            "DeviceToken": token
        ]
        
        apiAmbassador.post("/deviceToken", parameters: parameters as [String : AnyObject], success: { reponse in
        
        })

    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        
    }
    
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        
        let isFacebookURL = (url.scheme?.hasPrefix("fb\(FBSDKSettings.appID()!)"))! && url.host == "authorize"
        if isFacebookURL {
            return FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
        }
        
        if url.scheme! == "lightupon" {
            let urlString = url.absoluteString
            let queryArray = urlString.components(separatedBy: "/")
            let resource = queryArray[2]
            let id = Int(queryArray[3])
            self.deepLink = DeepLink(resource: resource, id: id ?? 0)
            self.window?.rootViewController = InitialLoadingViewController()
        }

        return false
    }
    
    func triggerDeepLinkIfPresent(callback: (DeepLink) -> Void) {
        if let link = deepLink {
            callback(link)
            deepLink = nil
        }
    }
    
    func applicationHandleRemoteNotification(_ application: UIApplication, didReceiveRemoteNotification userInfo: [String : String]) {

    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        FBSDKAppEvents.activateApp()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

