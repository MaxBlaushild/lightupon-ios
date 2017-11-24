 //
//  PostService.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 11/3/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//

import UIKit
import ObjectMapper

class PostService: NSObject {
    private let _awsService: AwsService
    private let _apiAmbassador: AmbassadorToTheAPI
    private let _litService: LitService
    private let _currentLocationService: CurrentLocationService
    private let _tripsService: TripsService
    
    private var getURL = ""
    private var awaitingGetURL = false
    private var card: Card!
    private var scene: Scene!
    private var tripID: Int?
    private var sceneID: Int?
    
    public var activeScene: Scene?
    
    public let postNotificationName = Notification.Name("OnScenePosted")
    
    init(
        awsService: AwsService,
        apiAmbassador: AmbassadorToTheAPI,
        litService: LitService,
        currentLocationService: CurrentLocationService,
        tripsService: TripsService
    ){
        _awsService = awsService
        _apiAmbassador = apiAmbassador
        _litService = litService
        _currentLocationService = currentLocationService
        _tripsService = tripsService
    }
    
    
    func uploadPicture(image: UIImage) {
        let name = Helper.randomString(length: 18)
        _awsService.uploadImage(name: name, image: image, callback: { url in
            self.getURL = url
            if self.awaitingGetURL {
                self.createContent()
            }
        })
    }
    
    func getActiveScene(callback: @escaping (Scene) -> Void) {
        let lat = _currentLocationService.latitude
        let lon = _currentLocationService.longitude
        _apiAmbassador.get("/activeScene?lat=\(lat)&lon=\(lon)", success: { response in
            let scene = Mapper<Scene>().map(JSONObject: response.result.value)
            callback(scene!)
        })
    }
    
    func post(card: Card, scene: Scene, tripID: Int?, sceneID: Int?) {
        self.card = card
        self.scene = scene
        self.tripID = tripID
        self.sceneID = sceneID
        
        if getURL.isEmpty {
            self.awaitingGetURL = true
        } else {
            createContent()
        }
    }
    
    func createContent() {
        let degenerateTrip = Trip(title: "", details: "")
        _tripsService.createTrip(degenerateTrip, callback: { trip in
            self.appendScene(self.scene, toTrip: trip.id, callback: { scene in
                self.card.sceneID = scene.id
                self.createCard(self.card, sceneID: scene.id, lat: scene.latitude, long: scene.longitude)
            })
        })
    }
    
    func createCard(_ card: Card, sceneID: Int, lat: Double?, long: Double?) {
        let newCard = [
            "Caption": card.caption,
            "ImageURL": getURL,
            "ShareOnFacebook": card.shareOnFacebook,
            "ShareOnTwitter": card.shareOnTwitter,
            "Latitude": lat ?? _currentLocationService.latitude,
            "Longitude": long ?? _currentLocationService.longitude
        ] as [String : Any]
        
        _apiAmbassador.post("/scenes/\(sceneID)/cards", parameters: newCard as [String : AnyObject], success: { response in
            NotificationCenter.default.post(name: self.postNotificationName, object: sceneID)
        })
    }
    
    func appendScene(_ scene: Scene, toTrip tripID: Int, callback: @escaping (Scene) -> Void) {
        let scene = [
            "ID": scene.id,
            "Latitude": scene.latitude ?? _currentLocationService.latitude,
            "Longitude": scene.longitude ?? _currentLocationService.longitude,
            "Name": scene.name,
            "Route": scene.route,
            "StreetNumber": scene.streetNumber,
            "BackgroundUrl": getURL
            ] as [String : Any]
        
        _apiAmbassador.post("/trips/\(tripID)/scenes", parameters: scene as [String : AnyObject], success: { response in
            let scene = Mapper<Scene>().map(JSONObject: response.result.value)
            callback(scene!)
        })
        
    }
    
}
