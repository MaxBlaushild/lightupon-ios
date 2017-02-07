//
//  Scene.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 5/15/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//

import Foundation

import UIKit
import ObjectMapper

class Scene: NSObject, Mappable {
    var id:Int?
    var tripId:Int?
    var trip: Trip?
    var name:String?
    var latitude: Double?
    var longitude: Double?
    var cards: [Card] = [Card]()
    var soundResource:String?
    var backgroundUrl: String?
    var sceneOrder: Int?
    var createdAt: Date?
    var updatedAt: Date?
    var locality: String?
    var state: String?
    var neighborhood: String?
    var constellationPoint: ConstellationPoint?
    var comments: [Comment] = [Comment]()
    var liked: Bool?
    var image: UIImage?
    
    func mapping(map: Map) {
        id                 <- map["ID"]
        name               <- map["Name"]
        latitude           <- map["Latitude"]
        longitude          <- map["Longitude"]
        cards              <- map["Cards"]
        tripId             <- map["TripID"]
        trip               <- map["Trip"]
        locality           <- map["Locality"]
        neighborhood       <- map["Neighborhood"]
        state              <- map["AdministrativeLevelOne"]
        constellationPoint <- map["ConstellationPoint"]
        soundResource      <- map["SoundResource"]
        backgroundUrl      <- map["BackgroundUrl"]
        sceneOrder         <- map["SceneOrder"]
        comments           <- map["Comments"]
        createdAt          <- (map["CreatedAt"], ISO8601MilliDateTransform())
        updatedAt          <- (map["UpdatedAt"], ISO8601MilliDateTransform())
        liked              <- map["Liked"]
    }
    
    required init?(map: Map) {}
    
    var location: Location {
        get {
            return Location(longitude: self.longitude!, latitude: self.latitude!)
        }
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
    
    override init() {
        super.init()
    }
}



