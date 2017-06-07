//
//  UserService.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 10/8/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//

import UIKit
import ObjectMapper

class UserService: NSObject {
    
    private let _apiAmbassador:AmbassadorToTheAPI
    private let _litService:LitService
    private let _followService:FollowService
    private let _facebookService:FacebookService
    private let _loginService: LoginService
    
    fileprivate var _currentUser: User!
    
    init(
        apiAmbassador: AmbassadorToTheAPI,
        litService:LitService,
        followService: FollowService,
        facebookService: FacebookService,
        loginService: LoginService
    ){
        _apiAmbassador = apiAmbassador
        _litService = litService
        _followService = followService
        _facebookService = facebookService
        _loginService = loginService
    }
    
    func getMyself(successCallback: @escaping () -> Void) {
        _facebookService.getMyProfile({ profile in
            self._loginService.upsertUser(profile, callback: {
                self._apiAmbassador.get("/me", success: { response in
                    self.setMyself(jsonObject: response.result.value as AnyObject)
                    successCallback()
                })
            })
        })

    }
    
    func setMyself(jsonObject: AnyObject) {
        let user = Mapper<User>().map(JSONObject: jsonObject)
        _currentUser = user
        _litService.setLitness(lit: _currentUser.lit!)
    }
    
    func isUser(_ otherProfile: FacebookProfile) -> Bool {
        return _currentUser.email == otherProfile.email
    }
    
    func getUser(_ userID: Int, success: @escaping (User) -> Void) {
        _apiAmbassador.get("/users/\(userID)", success: { response in
            let user = Mapper<User>().map(JSONObject: response.result.value) ?? User()
            success(user)
        })
    }
    
    var currentUser:User {
        get {
            return _currentUser!
        }
    }
}
