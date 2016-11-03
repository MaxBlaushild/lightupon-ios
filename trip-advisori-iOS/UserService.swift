//
//  UserService.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 10/8/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//

import UIKit
import ObjectMapper

class UserService: Service {
    
    private let _apiAmbassador:AmbassadorToTheAPI
    private let _litService:LitService
    private let _followService:FollowService
    
    fileprivate var _currentUser: User!
    
    init(apiAmbassador: AmbassadorToTheAPI, litService:LitService, followService: FollowService){
        _apiAmbassador = apiAmbassador
        _litService = litService
        _followService = followService
    }
    
    func getMyself(successCallback: @escaping () -> Void) {
        _apiAmbassador.get(apiURL + "/me", success: { response in
            self.setMyself(jsonObject: response.result.value as AnyObject)
            successCallback()
        })
    }
    
    func setMyself(jsonObject: AnyObject) {
        let user = Mapper<User>().map(JSONObject: jsonObject)
        _currentUser = user
        _followService.setFollows(follows: (user?.follows)!)
        _litService.setLitness(lit: _currentUser.lit!)
    }
    
    func isUser(_ otherProfile: FacebookProfile) -> Bool {
        return _currentUser.email == otherProfile.email
    }
    
    var currentUser:User {
        get {
            return _currentUser!
        }
    }
}
