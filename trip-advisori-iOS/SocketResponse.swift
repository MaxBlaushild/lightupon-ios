//
//  SocketResponse.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 5/15/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//

import Foundation

import UIKit
import ObjectMapper

class SocketResponse: NSObject, Mappable {
    var nextSceneAvailable: Bool?
    var currentSceneOrder: Int?
    var event: String?
    var updatedSceneID: Int = 0
    
    func mapping(map: Map) {
        nextSceneAvailable <- map["NextSceneAvailable"]
        currentSceneOrder  <- map["CurrentSceneOrder"]
        event              <- map["Event"]
        updatedSceneID     <- map["UpdatedSceneID"]
        
    }
    
    required init?(map: Map) {
        
    }
}
