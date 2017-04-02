//
//  Party.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 3/15/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//

import UIKit
import ObjectMapper

class Party: NSObject, Mappable {
    var id:Int?
    var trip: Trip?
    var passcode: String?
    var currentSceneOrder: Int?
    var createdAt: Date?
    var updatedAt: Date?
    
    func mapping(map: Map) {
        id                <- map["ID"]
        trip              <- map["Trip"]
        passcode          <- map["Passcode"]
        currentSceneOrder <- map["CurrentSceneOrderID"]
        createdAt         <- (map["CreatedAt"], ISO8601MilliDateTransform())
        updatedAt         <- (map["UpdatedAt"], ISO8601MilliDateTransform())
    }
    
    required init?(map: Map) {
        
    }
    
    func nextScene() -> Scene? {
        if let sceneOrder = currentSceneOrder {
            let nextSceneOrder = sceneOrder + 1
            if let partyTrip = trip {
                if partyTrip.scenes.indices.contains(nextSceneOrder) {
                    return partyTrip.scenes[nextSceneOrder]
                }
            }
        }
        return nil
    }
    
    var currentScene: Scene {
        get {
            return trip!.getSceneWithOrder(currentSceneOrder!)
        }
    }
}

