//
//  GoogleMapsService.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 1/27/17.
//  Copyright © 2017 Blaushild, Max. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import GoogleMaps

class GoogleMapsService: NSObject {
    let baseURL = "https://maps.googleapis.com/maps/api"
    
    func getDirections(origin: Location, destination: Location, mode:String = "walking", callback: @escaping (GMSPath) -> Void) {
        let url = "\(baseURL)/directions/json?origin=\(origin.latitude!),\(origin.longitude!)&destination=\(destination.latitude!),\(destination.longitude!)&mode=\(mode)&key=\(googleMapsApiKey)"
        
        Alamofire.request(url, method: .get).responseJSON { response in
            let parsedData = JSON(response.data as Any)
            if let pathString = parsedData["routes"][0]["overview_polyline"]["points"].string {
                let path = GMSPath(fromEncodedPath: pathString)
                callback(path!)
            }
        }
    }
}
