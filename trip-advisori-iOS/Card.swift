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
    var identifier: String?
    var nibId: String?
    var textTwo: String?
    var createdAt: Date?
    var updatedAt: Date?
    
    
    func mapping(map: Map) {
        id         <- map["ID"]
        cardType   <- map["CardType"]
        text       <- map["Text"]
        textTwo    <- map["TextTwo"]
        imageUrl   <- map["ImageURL"]
        cardOrder  <- map["CardOrder"]
        universal  <- map["Universal"]
        identifier <- map["Identifier"]
        nibId      <- map["NibID"]
        createdAt  <- (map["CreatedAt"], ISO8601MilliDateTransform())
        updatedAt  <- (map["UpdatedAt"], ISO8601MilliDateTransform())
    }
    
    required init?(map: Map) {
        
    }
}
