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

class PartyState: NSObject, Mappable {
    var nextSceneAvailable: Bool?
    var scene: Scene?
    var users: [User]?
    
    func mapping(map: Map) {
        nextSceneAvailable <- map["NextSceneAvailable"]
        scene              <- map["Scene"]
        users              <- map["Users"]
    }
    
    required init?(_ map: Map) {
        
    }
}
