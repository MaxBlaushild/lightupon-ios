//
//  NotificationService.swift
//  Lightupon
//
//  Created by Blaushild, Max on 1/28/17.
//  Copyright © 2017 Blaushild, Max. All rights reserved.
//

import UIKit
import UserNotifications

class NotificationService: NSObject {
    
    func requestNotificicationAuthorization(complete: @escaping () -> Void) {
  
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge], completionHandler: { granted, error in
                UIApplication.shared.registerForRemoteNotifications()
                complete()
            })
        } else {
            let type: UIUserNotificationType = [UIUserNotificationType.badge, UIUserNotificationType.alert, UIUserNotificationType.sound]
            let setting = UIUserNotificationSettings(types: type, categories: nil)
            UIApplication.shared.registerUserNotificationSettings(setting)
            UIApplication.shared.registerForRemoteNotifications()
            complete()
            
        }
    }

}
