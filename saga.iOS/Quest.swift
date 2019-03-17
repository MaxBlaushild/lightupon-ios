//
//  Quest.swift
//  Saga
//
//  Created by Max Blaushild on 3/2/19.
//  Copyright © 2019 Blaushild, Max. All rights reserved.
//

import Foundation
import ObjectMapper

class Quest: NSObject, Mappable {
    var id:Int = 0
    var title: String = ""
    var timeToComplete: Int = 0
    var posts: [Post] =  [Post]()
    var questProgress: QuestProgress = QuestProgress()
    
    func mapping(map: Map) {
        id                <- map["ID"]
        title             <- map["Description"]
        timeToComplete    <- map["TimeToComplete"]
        posts             <- map["Posts"]
        questProgress     <- map["QuestProgress"]
    }
    
    required init?(map: Map) {}
    
    var nextPost: Post? {
        get {
            posts.sort { one, two in
                return one.questOrder < two.questOrder
            }
            let nextPostIndex = questProgress.completedPosts
            return posts.indices.contains(nextPostIndex) ? posts[nextPostIndex] : nil
        }
    }
}

