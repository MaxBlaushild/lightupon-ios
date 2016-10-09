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
import AVFoundation

class Scene: NSObject, Mappable {
    var id:Int?
    var name:String?
    var latitude: Double?
    var longitude: Double?
    var cards: [Card]?
    var soundResource:String?
    var backgroundUrl: String?
    var sceneOrder: Int?
    var createdAt: Date?
    var updatedAt: Date?
    
    func mapping(map: Map) {
        id            <- map["ID"]
        name          <- map["Name"]
        latitude      <- map["Latitude"]
        longitude     <- map["Longitude"]
        cards         <- map["Cards"]
        soundResource <- map["SoundResource"]
        backgroundUrl <- map["BackgroundUrl"]
        sceneOrder    <- map["SceneOrder"]
        createdAt     <- (map["CreatedAt"], ISO8601MilliDateTransform())
        updatedAt     <- (map["UpdatedAt"], ISO8601MilliDateTransform())
    }
    
    required init?(map: Map) {}
    
    override init() {
        super.init()
    }
}



