//
//  Trip.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 2/6/16.
//  Copyright © 2016 Blaushild, Max. All rights reserv6=+≠≠+++___++ed.
//

import UIKit
import ObjectMapper

class Trip: NSObject, Mappable {
    var id:Int?
    var latitude: Double?
    var longitude: Double?
    var title: String?
    var descriptionText: String?
    var imageUrl: String?
    var estimatedTime: String?
    var details:String?
    var scenes: [Scene]?
    var owner: User?
    var createdAt: Date?
    var updatedAt: Date?
    var locations: [Location]?
    
    func mapping(map: Map) {
        imageUrl        <- map["ImageUrl"]
        latitude        <- map["Latitude"]
        longitude       <- map["Longitude"]
        details         <- map["Details"]
        title           <- map["Title"]
        descriptionText <- map["Description"]
        id              <- map["ID"]
        estimatedTime   <- map["EstimatedTime"]
        scenes          <- map["Scenes"]
        owner           <- map["User"]
        locations       <- map["Locations"]
        createdAt       <- (map["CreatedAt"], ISO8601MilliDateTransform())
        updatedAt       <- (map["UpdatedAt"], ISO8601MilliDateTransform())
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
    
    func getSceneWithOrder(_ sceneOrder: Int) -> Scene {
        var sceneWithOrder: Scene = Scene()
        
        for scene in self.scenes! {
            if scene.sceneOrder! == sceneOrder {
                sceneWithOrder = scene
            }
        }
        return sceneWithOrder
    }
}

