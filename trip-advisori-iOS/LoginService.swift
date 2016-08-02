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
    
    private var authService:AuthService!
    
    init(_authService_: AuthService) {
      authService = _authService_
    }
    
    func upsertUser(profile: FacebookProfile, callback: () -> Void) {
        let url:String = apiURL + "/users"
        
        let user = [
            "FacebookId": profile.id!,
            "Email": profile.email!
        ]
        
        Alamofire.request(.POST, url, parameters: user, encoding: .JSON)
            .responseJSON { request, response, result in
                
            let json = JSON(result.value!)
            let token:String = json.string!
            
            self.authService.setToken(token)
            self.authService.setFacebookId(profile.id!)
                
            callback()

        }
    }

}
