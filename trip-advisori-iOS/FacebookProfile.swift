//
//  FacebookProfile.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 2/14/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//

import UIKit
import SwiftyJSON

class FacebookProfile: NSObject {
    var firstName: String = ""
    var fullName: String = ""
    var email: String = ""
    var id:String = ""
    var profilePictureURL: String = ""
   
    required init(json: JSON){
        let profile:[String: JSON] = json.dictionary!
        let picture:[String: JSON] = profile["picture"]!.dictionary!
        let data:[String: JSON] = picture["data"]!.dictionary!
        
        self.id = profile["id"]!.string!
        self.firstName = profile["first_name"]!.string!
        self.fullName = profile["name"]!.string!
        self.email = profile["email"]!.string!
        self.profilePictureURL = data["url"]!.string!

    }
}


