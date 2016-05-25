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

    func getProfile(callback: (FacebookProfile) -> Void){
        
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me?fields=id,name,email,first_name,picture.width(800).height(800)", parameters: nil)
        
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            
            if ((error) != nil) {
                
                print("Error: \(error)")
                
            } else {
                
                let json = JSON(result!)
                
                let profile = FacebookProfile(json: json)
                
                callback(profile)
            }
        })
    }
    
    func getLoginInfo(callback: (FacebookProfile) -> Void){
        
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me?fields=id,name,email,first_name,picture.width(800).height(800)", parameters: nil)
        
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            
            if ((error) != nil) {
                
                print("Error: \(error)")
                
            } else {
                
                let json = JSON(result!)
                
                let profile = FacebookProfile(json: json)
                
                callback(profile)
            }
        })
    }
    
    
}
