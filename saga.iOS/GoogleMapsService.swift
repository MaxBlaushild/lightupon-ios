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
    let defaultUnlockedZoom: Float = 15.00
    let defaultLockedZoom: Float = 18.00
    var zoom: Float = 18.00
    
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
    
    func getAddress(lat: Double, lon: Double, callback: @escaping (Address) -> Void) {
        let url = "\(baseURL)/geocode/json?latlng=\(lat),\(lon)&key=\(googleMapsApiKey)"
        
        Alamofire.request(url, method: .get).responseJSON { response in
            let parsedData = JSON(response.data as Any)
            let address = Address()
            address.streetNumber = parsedData["results"][0]["address_components"][0]["short_name"].string ?? ""
            address.route = parsedData["results"][0]["address_components"][1]["short_name"].string ?? ""
            address.neighborhood = parsedData["results"][0]["address_components"][2]["short_name"].string ?? ""
            address.locality = parsedData["results"][0]["address_components"][3]["short_name"].string ?? ""
            address.googlePlaceId = parsedData["results"][0]["place_id"].string ?? ""
            address.latitude = lat
            address.longitude = lon
            callback(address)
        }
    }
}
