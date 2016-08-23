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
    }
    
    required init?(_ map: Map) {
        
    }
}

