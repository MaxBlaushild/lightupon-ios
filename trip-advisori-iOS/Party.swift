//
//  Party.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 3/15/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//

import UIKit
import SwiftyJSON

class Party: NSObject {
    
    var id:Int
    var trip: Trip
    var passcode: String
    
    required init(json:JSON){
        var party:[String: JSON] = json.dictionary!
        
        self.id = party["ID"]!.int!
        self.trip = Trip(json: json["Trip"])
        self.passcode = party["Passcode"]!.string!
    }
}

