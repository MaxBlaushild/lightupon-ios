//
//  QuestProgress.swift
//  Saga
//
//  Created by Max Blaushild on 3/3/19.
//  Copyright © 2019 Blaushild, Max. All rights reserved.
//

import Foundation
import ObjectMapper

class QuestProgress: NSObject, Mappable {
    
    var completedPosts:Int = 0
    
    func mapping(map: Map) {
        completedPosts    <- map["CompletedPosts"]
    }
    
    required init?(map: Map) {}
    
    override init() {}
    
}

