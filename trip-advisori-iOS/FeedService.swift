//
//  FeedService.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 12/19/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//

import UIKit
import ObjectMapper
import CoreLocation

class FeedService: NSObject, SocketServiceDelegate {
    private let _apiAmbassador: AmbassadorToTheAPI
    private let _currentLocationService: CurrentLocationService
    private let _socketService: SocketService
    
    public let sceneUpdatedSubscriptionName = Notification.Name("OnSceneUpdated")
    
    init(apiAmbassador: AmbassadorToTheAPI, currentLocationService: CurrentLocationService, socketService: SocketService) {
        _apiAmbassador = apiAmbassador
        _currentLocationService = currentLocationService
        _socketService = socketService
        
        super.init()
        
        _socketService.registerDelegate(self)
    }
    
    func onSceneUpdated(sceneID: Int) {
        NotificationCenter.default.post(name: self.sceneUpdatedSubscriptionName, object: sceneID)
    }
    
    func getFeed(page: Int, success: @escaping ([Scene]) -> Void) {
        _apiAmbassador.get("/feed?page=\(page)", success: { response in
            let scenes = Mapper<Scene>().mapArray(JSONObject: response.result.value) ?? [Scene]()
            success(scenes)
        })
    }
    
    func getScene(_ sceneId: Int, success: @escaping (Scene) -> Void) {
        let backgroundQueue = DispatchQueue.global(qos: .background)
        _apiAmbassador.get("/scenes/\(sceneId)", queue: backgroundQueue, success: { response in
            let scene = Mapper<Scene>().map(JSONObject: response.result.value) ?? Scene()
            success(scene)
        })
    }
    
    func getPost(_ postId: Int, success: @escaping (Post) -> Void) {
        let backgroundQueue = DispatchQueue.global(qos: .background)
        _apiAmbassador.get("/scenes/\(postId)", queue: backgroundQueue, success: { response in
            let post = Mapper<Post>().map(JSONObject: response.result.value) ?? Post(caption: "")
            success(post)
        })
    }
    
    func getUsersFeed(userID: Int, success: @escaping ([Post]) -> Void) {
        _apiAmbassador.get("/users/\(userID)/posts", success: { response in
            let posts = Mapper<Post>().mapArray(JSONObject: response.result.value) ?? [Post]()
            success(posts)
        })
    }
    
    func getNearbyPosts(location: CLLocationCoordinate2D?, radius: Double?, numScenes: Int?, success: @escaping ([Post]) -> Void) {
        let loc = location ?? _currentLocationService.cllocation.coordinate
        let lat = loc.latitude
        let lon = loc.longitude
        let rad = radius ?? 10000.00
        let num = numScenes ?? 20
        let url = "/posts/nearby?lat=\(lat)&lon=\(lon)&radius=\(rad)&numScenes=\(num)"
        _apiAmbassador.get(url, success: { response in
            let post = Mapper<Post>().mapArray(JSONObject: response.result.value) ?? [Post]()
            
            success(post)
        })
    }
}
