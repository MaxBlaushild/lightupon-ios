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
    
    func mapping(map: Map) {
        id            <- map["ID"]
        name          <- map["Name"]
        latitude      <- map["Latitude"]
        longitude     <- map["Longitude"]
        cards         <- map["Cards"]
        soundResource <- map["SoundResource"]
        backgroundUrl <- map["BackgroundUrl"]
        sceneOrder    <- map["SceneOrder"]
    }
    
    required init?(_ map: Map) {}
    
    override init() {
        super.init()
    }
}



