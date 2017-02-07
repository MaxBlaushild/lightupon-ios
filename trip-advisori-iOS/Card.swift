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
    var text: String = "Caption of the card"
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
    
    func prettyTimeSinceCreation() -> String {
        let yearsSince = self.createdAt!.yearsSince()
        if yearsSince == 0 {
            let monthsSince = self.createdAt!.monthsSince()
            if monthsSince == 0 {
                let daysSince = self.createdAt!.daysSince()
                if daysSince == 0 {
                    let hoursSince = self.createdAt!.hoursSince()
                    if hoursSince == 0 {
                        let minutesSince = self.createdAt!.minutesSince()
                        if minutesSince == 0 {
                            let secondsSince = self.createdAt!.secondsSince()
                            return "\(secondsSince)s"
                        } else {
                            return "\(minutesSince)min"
                        }
                    } else {
                        return "\(hoursSince)h"
                    }
                } else {
                    return "\(daysSince)d"
                }
            } else {
                return "\(monthsSince)mon"
            }
        } else {
            return "\(yearsSince)y"
        }
    }
    
    func prettyTimeSinceLastWentOn() -> String {
        let yearsSince = self.updatedAt!.yearsSince()
        if yearsSince == 0 {
            let monthsSince = self.updatedAt!.monthsSince()
            if monthsSince == 0 {
                let daysSince = self.updatedAt!.daysSince()
                if daysSince == 0 {
                    let hoursSince = self.updatedAt!.hoursSince()
                    if hoursSince == 0 {
                        let minutesSince = self.updatedAt!.minutesSince()
                        if minutesSince == 0 {
                            let secondsSince = self.updatedAt!.secondsSince()
                            return "\(secondsSince)s"
                        } else {
                            return "\(minutesSince)min"
                        }
                    } else {
                        return "\(hoursSince)h"
                    }
                } else {
                    return "\(daysSince)d"
                }
            } else {
                return "\(monthsSince)mon"
            }
        } else {
            return "\(yearsSince)y"
        }
    }
}
