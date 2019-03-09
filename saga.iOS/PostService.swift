 //
//  PostService.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 11/3/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//

import UIKit
import ObjectMapper
import Promises
 
class PostService: NSObject {
    private let _awsService: AwsService
    private let _apiAmbassador: AmbassadorToTheAPI
    private let _currentLocationService: CurrentLocationService
    
    private var getURL = ""
    private var awaitingGetURL = false
    private var post: Post!
    
    public let postNotificationName = Notification.Name("OnScenePosted")
    
    init(
        awsService: AwsService,
        apiAmbassador: AmbassadorToTheAPI,
        currentLocationService: CurrentLocationService
    ){
        _awsService = awsService
        _apiAmbassador = apiAmbassador
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
    
    func post(post: Post) {
        self.post = post
        
        if getURL.isEmpty {
            self.awaitingGetURL = true
        } else {
            createContent()
        }
    }
    
    func completePost(postID: Int) -> Promise<Bool> {
        return Promise<Bool> { fulfill, reject in
            let emptyData = [:] as [String: AnyObject]
            self._apiAmbassador.post("/posts/\(postID)/complete", parameters: emptyData, success: { response in
                fulfill(true)
            })
        }
    }
    
    func createContent() {
        let newPost = [
            "Caption": post.caption,
            "ImageURL": getURL,
            "Name": post.name,
            "ShareOnFacebook": post.shareOnFacebook,
            "ShareOnTwitter": post.shareOnTwitter,
            "Latitude": post.latitude ?? _currentLocationService.latitude,
            "Longitude": post.longitude ?? _currentLocationService.longitude,
            "Locality": post.locality,
            "Neighborhood": post.neighborhood,
            "StreetNumber": post.streetNumber,
            "GooglePlaceID": post.googlePlaceID
            ] as [String : Any]
        
        _apiAmbassador.post("/posts", parameters: newPost as [String : AnyObject], success: { response in
            NotificationCenter.default.post(name: self.postNotificationName, object: 09)
        })
    }
}
