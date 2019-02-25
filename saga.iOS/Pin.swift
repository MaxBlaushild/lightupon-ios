//
//  Pin.swift
//  Lightupon
//
//  Created by Blaushild, Max on 12/6/17.
//  Copyright © 2017 Blaushild, Max. All rights reserved.
//

import UIKit
import ObjectMapper

class Pin: NSObject, Mappable {
    var id:Int?
    var url: String?
    var ownerId: Int?
    var ownerType: String?
    
    func mapping(map: Map) {
        id               <- map["ID"]
        url              <- map["Url"]
        ownerId          <- map["OwnerID"]
        ownerType        <- map["OwnerType"]
    }
    
    required init?(map: Map) {
        
    }

}
