//
//  FacebookAPIController.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 2/14/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//

import UIKit
import ObjectMapper

class FacebookService: NSObject {
    
    fileprivate let queryParams = "fields=id,name,email,first_name,picture.width(800).height(800)"
    
    internal var profile:FacebookProfile!

    func getMyProfile(_ callback: @escaping (FacebookProfile) -> Void){
        let graphRequest = FBSDKGraphRequest(graphPath: "me?\(queryParams)", parameters: nil)
        
        _ = graphRequest?.start(completionHandler: { (connection, result, error) -> Void in
            self.profile = Mapper<FacebookProfile>().map(JSONObject: result) ?? FacebookProfile()
            callback(self.profile)
        })
    }
    
    func getProfile(_ facebookId: String, callback: @escaping (FacebookProfile) -> Void){
        let graphRequest = FBSDKGraphRequest(graphPath: "\(facebookId)?\(queryParams)", parameters: nil)
        
        _ = graphRequest?.start(completionHandler: { (connection, result, error) -> Void in
            let profile = Mapper<FacebookProfile>().map(JSONObject: result) ?? FacebookProfile()
            callback(profile)
        })
    }
}
