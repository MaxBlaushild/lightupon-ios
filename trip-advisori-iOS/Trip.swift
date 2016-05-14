//
//  Trip.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 2/6/16.
//  Copyright © 2016 Blaushild, Max. All rights reserv6=+≠≠+++___++ed.
//

import UIKit
import SwiftyJSON

class Trip: NSObject {
    
    var id:Int
    var latitude: Double
    var longitude: Double
    var title: String
    var descriptionText: String
    var imageUrl: String
    
    required init(json:JSON){
        var trip:[String: JSON] = json.dictionary!
        
        self.imageUrl = trip["ImageUrl"]!.string!
        self.latitude = trip["Latitude"]!.double!
        self.longitude = trip["Longitude"]!.double!
        self.title = trip["Title"]!.string!
        self.descriptionText = trip["Description"]!.string!
        self.id = trip["ID"]!.int!
    }
}
