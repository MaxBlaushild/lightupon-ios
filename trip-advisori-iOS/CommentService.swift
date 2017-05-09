//
//  CommentsService.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 12/19/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//

import UIKit
import ObjectMapper

class CommentService: NSObject {
    fileprivate let _apiAmbassador: AmbassadorToTheAPI
    
    init(apiAmbassador: AmbassadorToTheAPI) {
        _apiAmbassador = apiAmbassador
    }
    
    func getCommentsFor(scene: Scene, success: @escaping ([Comment]) -> Void) {
        _apiAmbassador.get("/scenes/\(scene.id)/comments", success: { response in
            let comments = Mapper<Comment>().mapArray(JSONObject: response.result.value)
            success(comments!)
        })
    
    }
    
    func getCommentsFor(trip: Trip, success: @escaping ([Comment]) -> Void) {
        _apiAmbassador.get("/trips/\(trip.id!)/comments", success: { response in
            let comments = Mapper<Comment>().mapArray(JSONObject: response.result.value)
            success(comments!)
        })
        
    }
    
    func getCommentsFor(card: Card, success : @escaping ([Comment]) -> Void) {
        _apiAmbassador.get("/cards/\(card.id!)/comments", success: { response in
            let comments = Mapper<Comment>().mapArray(JSONObject: response.result.value)
            success(comments!)
        })
    }

}