//
//  Follow.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 11/3/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//

import UIKit
import ObjectMapper

class Follow: NSObject, Mappable {
    private let userService = Injector.sharedInjector.getUserService()
    
    var followedUserID: Int?
    var followingUserID: Int?
    
    
    func mapping(map: Map) {
        followingUserID  <- map["FollowingUserID"]
        followedUserID   <- map["FollowedUserID"]
    }
    
    required init?(map: Map) {
        
    }
    
    init(user: User) {
        self.followingUserID = userService.currentUser.id
        self.followedUserID = user.id
    }
}
