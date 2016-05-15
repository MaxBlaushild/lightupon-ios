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
    var nextScene: Scene?
    var Users: [User]?
    
    func mapping(map: Map) {
        nextSceneAvailable <- map["NextSceneAvailable"]
        nextScene          <- map["NextScene"]
        Users              <- map["Users"]
    }
    
    required init?(_ map: Map) {
        
    }
}
