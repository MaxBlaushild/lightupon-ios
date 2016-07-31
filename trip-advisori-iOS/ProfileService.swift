//
//  FacebookAPIController.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 2/14/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//

import UIKit
import SwiftyJSON

class ProfileService: Service {
    var _profile_: FacebookProfile!
    
    var profile: FacebookProfile {
        get {
            return _profile_
        }
    }

    func getMyProfile(callback: (FacebookProfile) -> Void){
        
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me?fields=id,name,email,first_name,picture.width(800).height(800),cover", parameters: nil)
        
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            
            if ((error) != nil) {
                
                print("Error: \(error)")
                
            } else {
                
                let json = JSON(result!)
                
                let profile = FacebookProfile(json: json)
                self._profile_ = profile
                callback(profile)
            }
        })
    }
    
    func getProfile(facebookId: String, callback: (FacebookProfile) -> Void){
        
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "\(facebookId)?fields=id,name,email,first_name,picture.width(800).height(800),cover", parameters: nil)
        
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            if ((error) != nil) {
                
                print("Error: \(error)")
                
            } else {
                
                let json = JSON(result!)
                
                let profile = FacebookProfile(json: json)
                
                
                
                
                self._profile_ = profile
                callback(profile)
            }
        })
    }
    
    func getLoginInfo(callback: (FacebookProfile) -> Void){
        
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me?fields=id,name,email,first_name,picture.width(800).height(800),cover", parameters: nil)
        
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            
            if ((error) != nil) {
                
                print("Error: \(error)")
                
            } else {
                
                let json = JSON(result!)
                
                let profile = FacebookProfile(json: json)
                self._profile_ = profile
                callback(profile)
            }
        })
    }
    
    
}
