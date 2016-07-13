//
//  MapHero.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 7/5/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//

import UIKit
import GoogleMaps

class MapHero: CardView, IAmACard {
    private let currentLocationService: CurrentLocationService = Injector.sharedInjector.getCurrentLocationService()
    
    @IBOutlet weak var mapView: GMSMapView!

    func bindCard() {
        mapView.camera = GMSCameraPosition.cameraWithLatitude(currentLocationService.latitude, longitude: currentLocationService.longitude, zoom: 8)
        mapView.myLocationEnabled = true
    }

}
