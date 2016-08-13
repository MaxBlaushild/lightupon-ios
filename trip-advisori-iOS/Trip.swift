//
//  Trip.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 2/6/16.
//  Copyright © 2016 Blaushild, Max. All rights reserv6=+≠≠+++___++ed.
//

import UIKit
import ObjectMapper

//class Trip: NSObject {
//    
//    var id:Int
//    var latitude: Double
//    var longitude: Double
//    var title: String
//    var descriptionText: String
//    var imageUrl: String
//    var estimatedTime: String
//    var details:String
//    
//    required init(json:JSON){
//        var trip:[String: JSON] = json.dictionary!
//        
//        self.imageUrl = trip["ImageUrl"]!.string!
//        self.latitude = trip["Latitude"]!.double!
//        self.longitude = trip["Longitude"]!.double!
//        self.details = trip["Details"]!.string!
//        self.title = trip["Title"]!.string!
//        self.descriptionText = trip["Description"]!.string!
//        self.id = trip["ID"]!.int!
//        let time = trip["EstimatedTime"]!.int!
//        let hours = time / 60
//        let minutes = time % 60
//        self.estimatedTime = "\(hours):\(minutes)h"
//    }
//}

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
    
    func mapping(map: Map) {
        imageUrl        <- map["ImageUrl"]
        latitude        <- map["Latitude"]
        longitude       <- map["Longitude"]
        details         <- map["Details"]
        title           <- map["Title"]
        descriptionText <- map["Description"]
        id              <- map["ID"]
        estimatedTime   <- map["EstimatedTime"]
    }
    
    required init?(_ map: Map) {
        
    }
}

