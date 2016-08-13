//
//  TripsAPIController.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 2/6/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Locksmith

class TripsService: Service {
    private var apiAmbassador: AmbassadorToTheAPI!
    
    init(_apiAmbassador_: AmbassadorToTheAPI){
        apiAmbassador = _apiAmbassador_
    }
    
    func getTrips(callback: ([Trip]) -> Void){
        apiAmbassador.get(apiURL + "/trips", success: { request, response, result in
                
                let json = JSON(result!.value!)
                
                let jsonTrips:[JSON] = json.array! as [JSON]
                
                var trips = [Trip]()
                
                for trip in jsonTrips {
                    
//                    trips.append(Trip(json: trip))
                    
                }
                
                callback(trips)
                
        })
    }
    
    func getTrip(tripId: Int, vc: TripDetailsViewController) {
        apiAmbassador.get(apiURL + "/trips/\(tripId)", success: { request, response, result in
            
            let json = JSON(result!.value!)
            
//            let trip = Trip(json: json)
            
//            vc.trip = trip
//            vc.tripTitle.text = trip.title
//            vc.tripDetailsLabel.text = trip.descriptionText
//            vc.tripDetailsPicture.imageFromUrl(trip.imageUrl)
            
        })
    }
}
