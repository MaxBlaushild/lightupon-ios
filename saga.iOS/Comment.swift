//
//  Comment.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 12/19/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//

import UIKit
import ObjectMapper

class Comment: NSObject, Mappable {
    var id: Int?
    var text: String?
    var owner: User?
    var trip: Trip?
    var scene: Scene?
    
    func mapping(map: Map) {
        id      <- map["ID"]
        text    <- map["Text"]
        owner   <- map["User"]
        trip    <- map["Trip"]
        scene   <- map["Scene"]
    }
    
    required init?(map: Map) {}
}
