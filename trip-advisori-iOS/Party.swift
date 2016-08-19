//
//  Party.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 3/15/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//

import UIKit
import ObjectMapper

class Party: NSObject, Mappable {
    var id:Int?
    var trip: Trip?
    var passcode: String?
    
    func mapping(map: Map) {
        id       <- map["ID"]
        trip     <- map["Trip"]
        passcode <- map["Passcode"]
    }
    
    required init?(_ map: Map) {
        
    }
}

