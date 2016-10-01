//
//  FacebookAPIController.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 2/14/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//

import UIKit
import ObjectMapper

class ProfileService: Service {
    
    private let queryParams = "fields=id,name,email,first_name,picture.width(800).height(800),cover"
    
    internal var profile:FacebookProfile!
    
    func isUser(otherProfile: FacebookProfile) -> Bool {
        return profile.email == otherProfile.email
    }

    func getMyProfile(callback: (FacebookProfile) -> Void){
        let graphRequest = FBSDKGraphRequest(graphPath: "me?\(queryParams)", parameters: nil)
        
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            self.profile = Mapper<FacebookProfile>().map(result)
            callback(self.profile!)
        })
    }
    
    func getProfile(facebookId: String, callback: (FacebookProfile) -> Void){
        let graphRequest = FBSDKGraphRequest(graphPath: "\(facebookId)?\(queryParams)", parameters: nil)
        
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            let profile = Mapper<FacebookProfile>().map(result)
            callback(profile!)
        })
    }
    
    func getLoginInfo(callback: (FacebookProfile) -> Void){
        let graphRequest = FBSDKGraphRequest(graphPath: "me?\(queryParams)", parameters: nil)
        
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            let profile = Mapper<FacebookProfile>().map(result)
            callback(profile!)

        })
    }
    
}
