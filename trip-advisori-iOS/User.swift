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
    static let profileService:ProfileService = Injector.sharedInjector.getProfileService()
    
    var id:Int?
    var email: String?
    var facebookId:String?
    var location: Location?
    var facebookProfile: FacebookProfile?
    
    func mapping(map: Map) {
        id         <- map["ID"]
        email      <- map["Email"]
        facebookId <- map["FacebookId"]
        location   <- map["Location"]
        
        self.populateProfile()
    }
    
    required init?(_ map: Map) {}
    
    func populateProfile() {
        User.profileService.getProfile(self.facebookId!, callback: self.setProfile)
    }
    
    func setProfile(profile: FacebookProfile){
        self.facebookProfile = profile
    }
}