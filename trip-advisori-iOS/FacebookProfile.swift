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
    var firstName: String?
    var fullName: String?
    var email: String?
    var id:String?
    var profilePictureURL: String?
    var coverPhoto:String?
    
    func mapping(map: Map) {
        id         <- map["id"]
        email      <- map["email"]
        firstName  <- map["first_name"]
        fullName   <- map["name"]
        profilePictureURL <- map["picture.data.url"]
        coverPhoto   <- map["cover.source"]
    }
    
    required init?(_ map: Map) {}
}


