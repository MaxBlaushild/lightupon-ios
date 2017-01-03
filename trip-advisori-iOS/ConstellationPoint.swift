//
//  ConstellationPoint.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 12/24/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//

import UIKit
import ObjectMapper

class ConstellationPoint: NSObject, Mappable {
    var deltaY: Double?
    var distanceToThePreviousPoint: Double = 1.0
    
    func mapping(map: Map) {
        deltaY                        <- map["DeltaY"]
        distanceToThePreviousPoint    <- map["DistanceToPreviousPoint"]
    }
    
    required init?(map: Map) {}
}
