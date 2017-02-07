//
//  PostService.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 11/3/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//

import UIKit

class PostService: NSObject {
    fileprivate let _awsService: AwsService
    fileprivate let _apiAmbassador: AmbassadorToTheAPI
    fileprivate let _litService: LitService
    fileprivate let _currentLocationService: CurrentLocationService
    
    init(awsService: AwsService, apiAmbassador: AmbassadorToTheAPI, litService: LitService, currentLocationService: CurrentLocationService){
        _awsService = awsService
        _apiAmbassador = apiAmbassador
        _litService = litService
        _currentLocationService = currentLocationService
    }
    
    func uploadPicture(image: UIImage, callback: @escaping () -> Void) {
        let name = Helper.randomString(length: 12)
        _awsService.uploadImage(name: name, image: image, callback: { url in
            self.postSelfie(getURL: url, callback: {
                callback()
            })

        })
    }
    
    func createSelfie(image: UIImage, callback: @escaping () -> Void) {
        self.uploadPicture(image: image, callback: callback)
    }
    
    func postSelfie(getURL: String, callback: @escaping () -> Void) {
        let url = _litService.isLit ? "/selfies" : "/trips"
        let selfie = [
            "Location": [
                "Latitude": _currentLocationService.latitude,
                "Longitude": _currentLocationService.longitude
            ],
            "ImageURL": getURL
        ] as [String : Any]
        
        _apiAmbassador.post(url, parameters: selfie as [String : AnyObject], success: { response in
            callback()
        })
        
    }
    
}
