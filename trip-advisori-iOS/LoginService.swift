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

class LoginService: Service {
    
    fileprivate let _authService: AuthService
    
    init(authService: AuthService) {
      _authService = authService
    }
    
    func upsertUser(_ profile: FacebookProfile, callback: @escaping () -> Void) {
        let url:String = apiURL + "/users"
        
        let user = [
            "FacebookId": profile.id!,
            "Email": profile.email!,
            "FullName": profile.fullName!,
            "FirstName": profile.firstName!,
            "ProfilePictureURL": profile.profilePictureURL!
        ]
        
        Alamofire.request(url, method: .post, parameters: user, encoding: JSONEncoding.default)
            .responseJSON { response in
                
            let json = JSON(response.result.value!)
            let token:String = json.string!
            
            self._authService.setToken(token)
            self._authService.setFacebookId(profile.id!)
                
            callback()

        }
    }
}
