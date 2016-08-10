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

class MapHero: CardView, IAmACard, GMSMapViewDelegate {
    private let currentLocationService: CurrentLocationService = Injector.sharedInjector.getCurrentLocationService()
    private var compassTwirler: NSTimer?
    private var count: Int = 0;
    @IBOutlet weak var sceneMapView: GMSMapView!
    @IBOutlet weak var compass: UIImageView!

    func bindCard() {
        sceneMapView.camera = GMSCameraPosition.cameraWithLatitude(currentLocationService.latitude, longitude: currentLocationService.longitude, zoom: 18)
        sceneMapView.myLocationEnabled = true
        sceneMapView.settings.scrollGestures = false
        sceneMapView.settings.zoomGestures = false
        sceneMapView.delegate = self
        sceneMapView.bringSubviewToFront(compass)
        placeNextSceneOnMap()
        let mapCenter = CLLocation(latitude: currentLocationService.latitude, longitude: currentLocationService.longitude)
        twirlCompass(mapCenter)
        sceneMapView.animateToBearing(currentLocationService.course)
        sceneMapView.animateToViewingAngle(30.0)

    }
    
    func twirlCompass(origin: CLLocation) {
        let destination = CLLocation(latitude: nextScene.latitude!, longitude: nextScene.longitude!)
        let bearing = getBearingBetweenTwoPoints1(origin, point2: destination)
        compass.transform = CGAffineTransformMakeRotation(CGFloat(bearing) * CGFloat(M_PI)/180);
    }
    
    func mapView(mapView: GMSMapView, didChangeCameraPosition cameraPosition: GMSCameraPosition) {
        let mapCenter = CLLocation(latitude: cameraPosition.target.latitude, longitude: cameraPosition.target.longitude)
        twirlCompass(mapCenter)
    }
    
    func placeNextSceneOnMap() {
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2DMake(nextScene.latitude!, nextScene.longitude!)
        marker.title = nextScene.name
        marker.map = sceneMapView
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
