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

class AwsService: Service {
    fileprivate let _apiAmbassador: AmbassadorToTheAPI
    fileprivate let _currentLocationService: CurrentLocationService
    
    init(apiAmbassador: AmbassadorToTheAPI, currentLocationService: CurrentLocationService){
        _apiAmbassador = apiAmbassador
        _currentLocationService = currentLocationService
    }
    
    func sendPicture(name: String, type: String, callback: @escaping (String) -> Void) {
        let paramaters = ["assetName": name,
                          "assetType": type]
        
        _apiAmbassador.post(apiURL + "/admin/assets/uploadUrls/", parameters: paramaters as [String : AnyObject], success: { response in
            if (response.response!.statusCode == 200) {
                let url = response.result.value
                callback(url as! String)
            }
        })
    }
}
