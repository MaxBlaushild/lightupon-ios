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
    
    private let _authService: AuthService
    
    init(authService: AuthService) {
      _authService = authService
    }
    
    func upsertUser(profile: FacebookProfile, callback: () -> Void) {
        let url:String = apiURL + "/users"
        
        let user = [
            "FacebookId": profile.id!,
            "Email": profile.email!
        ]
        
        Alamofire.request(.POST, url, parameters: user, encoding: .JSON)
            .responseJSON { response in
                
            let json = JSON(response.result.value!)
            let token:String = json.string!
            
            self._authService.setToken(token)
            self._authService.setFacebookId(profile.id!)
                
            callback()

        }
    }
}
