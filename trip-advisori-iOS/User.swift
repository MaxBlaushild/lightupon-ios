//
//  User.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 5/15/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//

import Foundation
import UIKit
import ObjectMapper

class User: NSObject, Mappable {
    var id:Int = 0
    var email: String = ""
    var facebookId:String = ""
    var fullName:String = ""
    var firstName:String = ""
    var profilePictureURL:String = ""
    var location: Location?
    var facebookProfile: FacebookProfile?
    var createdAt: Date?
    var updatedAt: Date?
    
    func mapping(map: Map) {
        id                <- map["ID"]
        email             <- map["Email"]
        facebookId        <- map["FacebookId"]
        location          <- map["Location"]
        fullName          <- map["FullName"]
        firstName         <- map["FirstName"]
        profilePictureURL <- map["ProfilePictureURL"]
        createdAt         <- (map["CreatedAt"], ISO8601MilliDateTransform())
        updatedAt         <- (map["UpdatedAt"], ISO8601MilliDateTransform())
    }
    
    required init?(map: Map) {}
    
    override init() {
        super.init()
    }
    
    var profile: FacebookProfile {
        get {
            return FacebookProfile(user: self)
        }
    }
}
