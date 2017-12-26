//
//  DiscoveryService.swift
//  Lightupon
//
//  Created by Blaushild, Max on 6/9/17.
//  Copyright © 2017 Blaushild, Max. All rights reserved.
//

import UIKit

class DiscoveryService: NSObject {
    
    let _apiAmbassador: AmbassadorToTheAPI
    let _currentLocationService: CurrentLocationService
    let _navigationService: NavigationService
    
    let minimumDiscoveryDistance: Double = 200.00

    init(apiAmbassador: AmbassadorToTheAPI, currentLocationService: CurrentLocationService, navigationService: NavigationService) {
        _apiAmbassador = apiAmbassador
        _currentLocationService = currentLocationService
        _navigationService = navigationService
    }
    
    func discover(marker: LightuponGMSMarker) {
        let currentLocation = _currentLocationService.cllocation
        let markerLocation = marker.cllocation
        let distanceAway = currentLocation.distance(from: markerLocation)
        if distanceAway < minimumDiscoveryDistance {
            let location = [
                "Latitude": currentLocation.coordinate.latitude,
                "Longitude": currentLocation.coordinate.longitude
            ] as [String : Any]
            
            _apiAmbassador.post("/scenes/\(marker.post.id)/discover", parameters: location as [String : AnyObject], success: { _ in
            }, failure: { _ in })
        }
    }
}
