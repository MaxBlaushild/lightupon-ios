//
//  AwsService.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 11/3/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//


import UIKit
import Alamofire
import ObjectMapper
import Locksmith

class AwsService: NSObject {
    fileprivate let _apiAmbassador: AmbassadorToTheAPI
    fileprivate let _currentLocationService: CurrentLocationService
    fileprivate let _extension: String = "jpg"
    
    init(apiAmbassador: AmbassadorToTheAPI, currentLocationService: CurrentLocationService){
        _apiAmbassador = apiAmbassador
        _currentLocationService = currentLocationService
    }
    
    func getPutUrl(name: String, type: String, callback: @escaping (String) -> Void) {
        
        
        let paramaters = ["name": "\(name).\(_extension)",
                          "type": type]
        
        _apiAmbassador.post("/admin/assets/uploadUrls", parameters: paramaters as [String : AnyObject], success: { response in
            if (response.response!.statusCode == 202) {
                let lightuponResponse = Mapper<LightuponResponse>().map(JSONObject: response.result.value)
                let url = lightuponResponse?.message
                callback(url!)
            }
        })
    }
    
    func getGetURL(putURL: String) -> String {
        return putURL.components(separatedBy: "?")[0]
    }
    
    func uploadImage(name: String, image: UIImage, callback: @escaping (String) -> Void) {
        getPutUrl(name: name, type: "images", callback: { url in
            self.putImage(url: url, image: image, callback: {
                let getURL = self.getGetURL(putURL: url)
                callback(getURL)
            })
        })
    }
    
    func putImage(url: String, image: UIImage, callback: @escaping () -> Void) {
        let imageData = UIImageJPEGRepresentation(image, 0.6)
        
        
        Alamofire.upload(imageData!, to: url, method: .put, headers: ["Content-Type":"image/\(_extension)", "x-amz-acl": "public-read"]).response { response in
            callback()
        }
    }
}
