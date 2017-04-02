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
    
    private var getURL = ""
    private var awaitingGetURL = false
    private var card: Card!
    private var scene: Scene!
    private var callback: (() -> Void)!
    
    init(awsService: AwsService, apiAmbassador: AmbassadorToTheAPI, litService: LitService, currentLocationService: CurrentLocationService){
        _awsService = awsService
        _apiAmbassador = apiAmbassador
        _litService = litService
        _currentLocationService = currentLocationService
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
    
    func post(card: Card, scene: Scene, callback: @escaping () -> Void) {
        self.card = card
        self.scene = scene
        self.callback = callback
        
        if getURL.isEmpty {
            self.awaitingGetURL = true
        } else {
            createContent()
        }
    }
    
    func createContent() {
        if _litService.isLit {
            if scene.id != 0 {
                createCard(card, sceneID: scene.id, callback: callback)
            } else {
                createScene(scene, callback: { scene in
                    self.card.sceneID = scene.id
                    self.createCard(self.card, sceneID: scene.id, callback: self.callback)
                })
            }
        } else {
            createDegenerateTrip(card: card, scene: scene, callback: callback)
        }
    }
    
    func createDegenerateTrip(card: Card, scene: Scene, callback: @escaping () -> Void) {
        let scene = [
            "ID": scene.id,
            "Latitude": scene.latitude ?? _currentLocationService.latitude,
            "Longitude": scene.longitude ?? _currentLocationService.longitude,
            "Name": scene.name,
            "Route": scene.route,
            "StreetNumber": scene.streetNumber,
            "BackgroundUrl": getURL,
            "Cards": [
                [
                    "Caption": card.caption,
                    "ImageURL": getURL
                ]
            ]] as [String : Any]
        
        _apiAmbassador.post("/trips/generate", parameters: scene as [String : AnyObject], success: { response in
            callback()
        })
    }
    
    func createCard(_ card: Card, sceneID: Int, callback: @escaping () -> Void) {
        let newCard = [
            "Capion": card.caption,
            "ImageURL": getURL
        ]
        _apiAmbassador.post("/scenes/\(sceneID)/cards", parameters: newCard as [String : AnyObject], success: { response in
            callback()
        })
    }
    
    func createScene(_ scene: Scene, callback: @escaping (Scene) -> Void) {
        let scene = [
            "ID": scene.id,
            "Latitude": scene.latitude ?? _currentLocationService.latitude,
            "Longitude": scene.longitude ?? _currentLocationService.longitude,
            "Name": scene.name,
            "Route": scene.route,
            "StreetNumber": scene.streetNumber,
            "BackgroundUrl": getURL
            ] as [String : Any]
        
        _apiAmbassador.post("/trips/active/scenes", parameters: scene as [String : AnyObject], success: { response in
            let scene = Mapper<Scene>().map(JSONObject: response.result.value)
            callback(scene!)
        })
        
    }
    
}
