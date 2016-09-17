//
//  CompassView.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 8/28/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//

import UIKit
import Foundation
import GoogleMaps
import Darwin

class CompassView: UIView, GMSMapViewDelegate, CurrentLocationServiceDelegate, SocketServiceDelegate  {
    
    private let currentLocationService = Injector.sharedInjector.getCurrentLocationService()
    private let navigationService = Injector.sharedInjector.getNavigationService()
    private let socketService = Injector.sharedInjector.getSocketService()
    
    @IBOutlet weak var sceneMapView: GMSMapView!
    @IBOutlet weak var compass: UIImageView!
    @IBOutlet weak var instructionsView: UIView!
    @IBOutlet weak var instructionsLabel: UILabel!
    
    private var _nextScene: Scene!
    
    func pointCompassTowardScene(nextScene: Scene) {
        _nextScene = nextScene
        
        sceneMapView.delegate = self
        currentLocationService.registerDelegate(self)
        socketService.registerDelegate(self)
        
        centerMapOnLocation()
        configureMapView()
        twirlCompass()
        bindTitleToInstructions()
        addNextScene()
        applyInstructionsView()
        
        sceneMapView.bringSubviewToFront(compass)
    }
    
    func configureMapView() {
        sceneMapView.myLocationEnabled = true
        sceneMapView.settings.zoomGestures = false
        sceneMapView.settings.scrollGestures = false
    }
    
    func applyInstructionsView() {
        instructionsView.addShadow()
        sceneMapView.bringSubviewToFront(instructionsView)
    }
    
    func createCenteredCameraPostion() -> GMSCameraPosition {
        return GMSCameraPosition.cameraWithLatitude(currentLocationService.latitude, longitude: currentLocationService.longitude, zoom: 17, bearing: currentLocationService.heading, viewingAngle: 0)
    }
    
    func onResponseReceived(_partyState_: PartyState) {
        if (_partyState_.nextSceneAvailable!) {
            animateOutCompass()
        }
    }
    
    func animateOutCompass() {
        UIView.animateWithDuration(0.5, animations: {
            self.compass.frame = CGRect(
                x: self.compass.frame.origin.x + self.compass.frame.width / 2,
                y: self.compass.frame.origin.y + self.compass.frame.height / 2,
                width: 0,
                height: 0
            )
        })
    }
    
    func bindTitleToInstructions() {
        let instructions = "Follow the arrow until you arrive at \(_nextScene!.name!)."
        instructionsLabel.text = instructions
    }
    
    func centerMapOnLocation() {
        let newCenter = self.createCenteredCameraPostion()
        sceneMapView.animateToCameraPosition(newCenter)
    }
    
    func addNextScene() {
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2DMake(_nextScene!.latitude!, _nextScene!.longitude!)
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
        let destination = CLLocation(latitude: _nextScene!.latitude!, longitude: _nextScene!.longitude!)
        let bearing = navigationService.getBearingBetweenTwoPoints1(origin, point2: destination)
        let normalizedDelta = navigationService.adjustBearingForDeviceHeading(bearing, heading: currentLocationService.heading)
        compass.transform = CGAffineTransformMakeRotation(normalizedDelta * CGFloat(M_PI)/180);
    }

}
