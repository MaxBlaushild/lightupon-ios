//
//  Scene.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 5/15/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//

import Foundation
import GoogleMaps
import UIKit
import ObjectMapper

class Scene: NSObject, Mappable {
    var id:Int = 0
    var tripId:Int = 0
    var trip: Trip?
    var name:String = ""
    var latitude: Double?
    var longitude: Double?
    var cards: [Card] = [Card]()
    var soundResource:String?
    var backgroundUrl: String = "http://p.fod4.com/p/channels/legacy/profile/1212782/a196f26e7efc0fc9c3890cdc748ce61d.jpg"
    var sceneOrder: Int?
    var createdAt: Date?
    var updatedAt: Date?
    var locality: String = ""
    var state: String?
    var neighborhood: String = ""
    var constellationPoint: ConstellationPoint?
    var comments: [Comment] = [Comment]()
    var liked: Bool?
    var image: UIImage?
    var formattedAddress: String?
    var streetNumber: String = ""
    var route: String = ""
    var googlePlaceID: String?
    var pinUrl: String?
    var selectedPinUrl: String?
    var hidden: Bool = false
    
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
        googlePlaceID      <- map["GooglePlaceID"]
        state              <- map["AdministrativeLevelOne"]
        constellationPoint <- map["ConstellationPoint"]
        soundResource      <- map["SoundResource"]
        backgroundUrl      <- map["BackgroundUrl"]
        sceneOrder         <- map["SceneOrder"]
        formattedAddress   <- map["FormattedAddress"]
        streetNumber       <- map["StreetNumber"]
        comments           <- map["Comments"]
        route              <- map["Route"]
        createdAt          <- (map["CreatedAt"], ISO8601MilliDateTransform())
        updatedAt          <- (map["UpdatedAt"], ISO8601MilliDateTransform())
        liked              <- map["Liked"]
        pinUrl             <- map["PinUrl"]
        selectedPinUrl     <- map["SelectedPinUrl"]
        hidden             <- map["Hidden"]
    }
    
    required init?(map: Map) {}
    
    var address: Address {
        get {
            let address = Address()
            address.streetNumber = streetNumber
            address.route = route
            address.locality = locality
            address.neighborhood = neighborhood
            address.googlePlaceId = googlePlaceID
            address.latitude = latitude
            address.longitude = longitude
            return address
            
        }
        
        set {
            streetNumber = newValue.streetNumber!
            route = newValue.route!
            locality = newValue.locality!
            neighborhood = newValue.neighborhood!
            googlePlaceID = newValue.googlePlaceId
            latitude = newValue.latitude
            longitude = newValue.longitude
        }
    }
    
    var location: Location {
        get {
            return Location(longitude: self.longitude!, latitude: self.latitude!)
        }
    }
    
    var cllocation: CLLocation {
        return CLLocation(latitude: self.latitude!, longitude: self.longitude!)
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



