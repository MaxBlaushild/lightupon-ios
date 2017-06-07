//
//  FacebookProfile.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 2/14/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//

import UIKit
import SwiftyJSON
import ObjectMapper

class FacebookProfile: NSObject, Mappable {
    var firstName: String = ""
    var fullName: String = ""
    var email: String = ""
    var id:String = ""
    var profilePictureURL: String = "http://p.fod4.com/p/channels/legacy/profile/1212782/a196f26e7efc0fc9c3890cdc748ce61d.jpg"
    var coverPhoto:String = "http://p.fod4.com/p/channels/legacy/profile/1212782/a196f26e7efc0fc9c3890cdc748ce61d.jpg"
    
    func mapping(map: Map) {
        id         <- map["id"]
        email      <- map["email"]
        firstName  <- map["first_name"]
        fullName   <- map["name"]
        profilePictureURL <- map["picture.data.url"]
    }
    
    required init?(map: Map) {}
    
    
    override init() {
        super.init()
    }
    
    
    init(user: User) {
        self.firstName = user.firstName
        self.fullName = user.fullName
        self.email = user.email
        self.id = user.facebookId
        self.profilePictureURL = user.profilePictureURL
    }
}


