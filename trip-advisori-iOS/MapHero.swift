//
//  MapHero.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 7/5/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//

import UIKit
import Foundation
import GoogleMaps
import Darwin

class MapHero: CardView, IAmACard, GMSMapViewDelegate, CurrentLocationServiceDelegate {
    private let currentLocationService: CurrentLocationService = Injector.sharedInjector.getCurrentLocationService()

    private var count: Int = 0;
    
    @IBOutlet weak var sceneMapView: GMSMapView!
    @IBOutlet weak var compass: UIImageView!
    
    func bindCard() {
        sceneMapView.delegate = self
        currentLocationService.delegate = self
        
        centerMapOnLocation()
        configureMapView()
        twirlCompass()
        addNextScene()
        
        sceneMapView.bringSubviewToFront(compass)
    }
    
    func configureMapView() {
        sceneMapView.myLocationEnabled = true
        sceneMapView.settings.zoomGestures = false
        sceneMapView.settings.scrollGestures = false
    }
    
    func createCenteredCameraPostion() -> GMSCameraPosition {
        return GMSCameraPosition.cameraWithLatitude(currentLocationService.latitude, longitude: currentLocationService.longitude, zoom: 17, bearing: currentLocationService.heading, viewingAngle: 0)
    }
    
    func centerMapOnLocation() {
        let newCenter = self.createCenteredCameraPostion()
        sceneMapView.animateToCameraPosition(newCenter)
    }
    
    func addNextScene() {
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2DMake(nextScene.latitude!, nextScene.longitude!)
        marker.title = "fuck"
        marker.snippet = "fuck"
        marker.map = sceneMapView
    }
    
    func onLocationUpdated() {
        centerMapOnLocation()
        twirlCompass()
    }
    
    func onHeadingUpdated() {
        realignMapView()
        twirlCompass()
    }
    
    func realignMapView() {
        let heading = currentLocationService.heading
        sceneMapView.animateToBearing(heading)
    }
    
    func twirlCompass() {
        let origin = CLLocation(latitude: currentLocationService.latitude, longitude: currentLocationService.longitude)
        let destination = CLLocation(latitude: nextScene.latitude!, longitude: nextScene.longitude!)
        let bearing = CGFloat(getBearingBetweenTwoPoints1(origin, point2: destination))
        let normalizedDelta = adjustBearingForDeviceHeading(bearing)
        compass.transform = CGAffineTransformMakeRotation((normalizedDelta % 360) * CGFloat(M_PI)/180);
    }
    
    func adjustBearingForDeviceHeading(bearing: CGFloat) -> CGFloat {
        let heading = CGFloat(currentLocationService.heading)
        let delta = bearing - heading
        let normalizedDelta = delta + 360
        return normalizedDelta
    }
    
    func degreesToRadians(degrees: Double) -> Double { return degrees * M_PI / 180.0 }
    func radiansToDegrees(radians: Double) -> Double { return radians * 180.0 / M_PI }
    
    func getBearingBetweenTwoPoints1(point1 : CLLocation, point2 : CLLocation) -> Double {
        
        let lat1 = degreesToRadians(point1.coordinate.latitude)
        let lon1 = degreesToRadians(point1.coordinate.longitude)
        
        let lat2 = degreesToRadians(point2.coordinate.latitude);
        let lon2 = degreesToRadians(point2.coordinate.longitude);
        
        let dLon = lon2 - lon1;
        
        let y = sin(dLon) * cos(lat2);
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);
        let radiansBearing = atan2(y, x);
        
        return radiansToDegrees(radiansBearing - 45)
    }

}
