//
//  Card.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 5/16/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//

import UIKit
import ObjectMapper

class Card: NSObject, Mappable {
    var id:Int?
    var cardType:String?
    var text: String?
    var imageUrl: String?
    var cardOrder: Int?
    var universal: Bool?
    
    
    func mapping(map: Map) {
        id        <- map["ID"]
        cardType  <- map["CardType"]
        text      <- map["Text"]
        imageUrl  <- map["ImageURL"]
        cardOrder <- map["CardOrder"]
        universal <- map["Universal"]
    }
    
    required init?(_ map: Map) {
        
    }
}
