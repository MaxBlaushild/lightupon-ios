//
//  Response.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 12/12/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//

import UIKit
import ObjectMapper

class LightuponResponse: NSObject, Mappable {
    var message: String?
    
    func mapping(map: Map) {
        message  <- map["message"]
    }
    
    required init?(map: Map) {}
}
