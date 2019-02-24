//
//  LoginAPIController.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 2/14/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Locksmith
import UserNotifications
import FBSDKLoginKit

class LoginService: NSObject {
    
    private let _authService: AuthService
    private let _notificationService: NotificationService
    private let _apiAmbassador: AmbassadorToTheAPI
    
    init(authService: AuthService, notificationService: NotificationService, apiAmbassador: AmbassadorToTheAPI) {
        _authService = authService
        _notificationService = notificationService
        _apiAmbassador = apiAmbassador
    }
    
    func upsertUser(_ profile: FacebookProfile, callback: @escaping () -> Void) {
        let user = [
            "FacebookId": profile.id,
            "FacebookToken": FBSDKAccessToken.current().tokenString,
            "Email": profile.email,
            "FullName": profile.fullName,
            "FirstName": profile.firstName,
            "ProfilePictureURL": profile.profilePictureURL
        ]
        
        _apiAmbassador.post("/users", parameters: user as [String : AnyObject], success: { response in
                
            let json = JSON(response.result.value!)
            let token:String = json.string!
            
            
            self._authService.setToken(token)
            self._authService.setFacebookId(profile.id)
                
            self._notificationService.requestNotificicationAuthorization(complete: {
                callback()
            })
        })
    }
}
