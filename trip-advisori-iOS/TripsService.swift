//
//  TripsAPIController.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 2/6/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//

import UIKit
import Alamofire
import ObjectMapper
import Locksmith

class TripsService: NSObject {
    fileprivate let _apiAmbassador: AmbassadorToTheAPI
    
    init(apiAmbassador: AmbassadorToTheAPI){
        _apiAmbassador = apiAmbassador
    }
    
    func getTrips(_ callback: @escaping ([Trip]) -> Void, latitude: Double, longitude: Double){
        let strLatitude = String(latitude)
        let strLongitude = String(longitude)
        _apiAmbassador.get("/trips?lat=" + strLatitude + "&lon=" + strLongitude, success: { response in
            let trips = Mapper<Trip>().mapArray(JSONObject: response.result.value)
            callback(trips!)
        })
    }
    
    func getTrip(_ tripId: Int, callback: @escaping (Trip) -> Void) {
        _apiAmbassador.get("/trips/\(tripId)", success: { response in
            let trip = Mapper<Trip>().map(JSONObject: response.result.value)
            callback(trip!)
        })
    }
    
    func getUsersTrips(_ userID: Int, callback: @escaping ([Trip]) -> Void) {
        _apiAmbassador.get("/users/\(userID)/trips", success: { response in
            let trips = Mapper<Trip>().mapArray(JSONObject: response.result.value)
            callback(trips!)
        })
    }
}
