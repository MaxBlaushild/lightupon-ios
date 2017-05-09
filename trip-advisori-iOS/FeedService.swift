//
//  FeedService.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 12/19/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//

import UIKit
import ObjectMapper

class FeedService: NSObject {
    private let _apiAmbassador: AmbassadorToTheAPI
    private let _currentLocationService: CurrentLocationService
    
    init(apiAmbassador: AmbassadorToTheAPI, currentLocationService: CurrentLocationService) {
        _apiAmbassador = apiAmbassador
        _currentLocationService = currentLocationService
    }
    
    func getFeed(success: @escaping ([Scene]) -> Void) {
        _apiAmbassador.get("/scenes", success: { response in
            let scenes = Mapper<Scene>().mapArray(JSONObject: response.result.value)
            success(scenes!)
        })
    }
    
    func getScene(_ sceneId: Int, success: @escaping (Scene) -> Void) {
        _apiAmbassador.get("/scenes/\(sceneId)", success: { response in
            let scene = Mapper<Scene>().map(JSONObject: response.result.value)
            success(scene!)
        })
    }
    
    func getUsersFeed(userID: Int, success: @escaping ([Scene]) -> Void) {
        _apiAmbassador.get("/users/\(userID)/scenes", success: { response in
            let scenes = Mapper<Scene>().mapArray(JSONObject: response.result.value)
            success(scenes!)
        })
    }
    
    func getNearbyScenes(success: @escaping ([Scene]) -> Void) {
        let lat = _currentLocationService.latitude
        let lon = _currentLocationService.longitude
        let url = "/scenes/nearby?lat=\(lat)&lon=\(lon)"
        _apiAmbassador.get(url, success: { response in
            let scenes = Mapper<Scene>().mapArray(JSONObject: response.result.value)
            success(scenes!)
        })
    }
}
