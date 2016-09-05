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

class TripsService: Service {
    private let _apiAmbassador: AmbassadorToTheAPI
    
    init(apiAmbassador: AmbassadorToTheAPI){
        _apiAmbassador = apiAmbassador
    }
    
    func getTrips(callback: ([Trip]) -> Void, latitude: Double, longitude: Double){
        let strLatitude = String(latitude)
        let strLongitude = String(longitude)
        _apiAmbassador.get(apiURL + "/trips?lat=" + strLatitude + "&lon=" + strLongitude, success: { response in
            let trips = Mapper<Trip>().mapArray(response.result.value)
            callback(trips!)
        })
    }
    
    func getTrip(tripId: Int, callback: (Trip) -> Void) {
        _apiAmbassador.get(apiURL + "/trips/\(tripId)", success: { response in
            let trip = Mapper<Trip>().map(response.result.value)
            callback(trip!)
        })
    }
}
