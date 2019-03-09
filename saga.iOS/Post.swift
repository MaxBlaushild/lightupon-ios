//
//  Post.swift
//  Lightupon
//
//  Created by Blaushild, Max on 12/6/17.
//  Copyright © 2017 Blaushild, Max. All rights reserved.
//

import UIKit
import ObjectMapper
import GoogleMaps

class Post: NSObject, Mappable {
    var id:Int = 0
    var imageUrl: String = "http://p.fod4.com/p/channels/legacy/profile/1212782/a196f26e7efc0fc9c3890cdc748ce61d.jpg"
    var identifier: String?
    var createdAt: Date?
    var pin: Pin?
    var caption: String = "Caption of the card"
    var updatedAt: Date?
    var shareOnFacebook: Bool = false
    var shareOnTwitter: Bool = false
    var percentDiscovered: CGFloat = 0.0
    var latitude: Double? = 0.0
    var longitude: Double? = 0.0
    var owner: User?
    var streetNumber: String = ""
    var route: String = ""
    var googlePlaceID: String?
    var locality: String = ""
    var state: String?
    var neighborhood: String = ""
    var name = ""
    var completed = false
        
    func mapping(map: Map) {
        id                <- map["ID"]
        caption           <- map["Caption"]
        imageUrl          <- map["ImageUrl"]
        createdAt         <- (map["CreatedAt"], ISO8601MilliDateTransform())
        updatedAt         <- (map["UpdatedAt"], ISO8601MilliDateTransform())
        percentDiscovered <- map["PercentDiscoverd"]
        latitude          <- map["Latitude"]
        longitude         <- map["Longitude"]
        owner             <- map["User"]
        locality          <- map["Locality"]
        neighborhood      <- map["Neighborhood"]
        googlePlaceID     <- map["GooglePlaceID"]
        state             <- map["AdministrativeLevelOne"]
        pin               <- map["Pin"]
        name              <- map["Name"]
        streetNumber      <- map["StreetNumber"]
        completed         <- map["Completed"]
    }
    
    required init?(map: Map) {
        
    }
    
    init(caption: String) {
        self.caption = caption
    }
    
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
            latitude = newValue.latitude ?? 0.0
            longitude = newValue.longitude ?? 0.0
            
        }
    }
    
    var location: Location {
        get {
            return Location(longitude: self.longitude ?? 0.0, latitude: self.latitude ?? 0.0)
        }
    }
    
    var cllocation: CLLocation {
        return CLLocation(latitude: self.latitude ?? 0.0, longitude: self.longitude ?? 0.0)
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
