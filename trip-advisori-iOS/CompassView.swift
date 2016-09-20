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

@objc protocol CompassViewDelegate {
    func goToNextScene() -> Void
}

class CompassView: UIView, GMSMapViewDelegate, CurrentLocationServiceDelegate, SocketServiceDelegate  {
    
    private let currentLocationService = Injector.sharedInjector.getCurrentLocationService()
    private let navigationService = Injector.sharedInjector.getNavigationService()
    private let socketService = Injector.sharedInjector.getSocketService()
    
    @IBOutlet weak var sceneMapView: GMSMapView!
    @IBOutlet weak var compass: UIImageView!
    @IBOutlet weak var instructionsView: UIView!
    @IBOutlet weak var instructionsLabel: UILabel!
    var nextSceneButton: UIButton!
    
    internal var delegate: CompassViewDelegate!
    
    private var _nextScene: Scene!
    private var _isAtNextScene: Bool = false
    private var _ogCompassFrame: CGRect!
    
    func pointCompassTowardScene(nextScene: Scene) {
        _nextScene = nextScene
        
        sceneMapView.delegate = self
        currentLocationService.registerDelegate(self)
        socketService.registerDelegate(self)
        
        setCompassSize()
        centerMapOnLocation()
        configureMapView()
        twirlCompass()
        bindTitleToInstructions()
        addNextScene()
        applyInstructionsView()
        
        sceneMapView.bringSubviewToFront(compass)
    }
    
    func setCompassSize() {
        _ogCompassFrame = compass.frame
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
    
    func onResponseReceived(partyState: PartyState) {
        
        if (partyState.nextSceneAvailable! != _isAtNextScene) {
            if (partyState.nextSceneAvailable!) {
                animateOutCompass()
            } else {
                animateOutNextSceneButton()
            }
        }
        _isAtNextScene = partyState.nextSceneAvailable!

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
    
    func addNextSceneButton() {
        createNextSceneButton()
        addSubview(nextSceneButton)
        animateInNextSceneButton()
    }
    
    func createNextSceneButton() {
        nextSceneButton = UIButton(type: .Custom)
        nextSceneButton.frame = compassCenter()
        nextSceneButton.addTarget(delegate, action: #selector(delegate.goToNextScene), forControlEvents: .TouchUpInside)
    }
    
    func animateInNextSceneButton() {
        UIView.animateWithDuration(0.5, animations: {
            self.nextSceneButton.frame = self.compassSize()
            self.nextSceneButton.layer.cornerRadius = 0.5 * self.nextSceneButton.bounds.size.width
            self.nextSceneButton.backgroundColor = UIColor.whiteColor()
            self.nextSceneButton.addShadow()
        })
    }
    
    func animateOutNextSceneButton() {
        UIView.animateWithDuration(0.5, animations: {
            self.nextSceneButton.frame = self.compassCenter()
        },
        completion: { truth in
            self.animateInCompass()
        })
    }
    
    func animateOutCompass() {
        UIView.animateWithDuration(0.5, animations: {
            self.compass.transform = CGAffineTransformMakeScale(0.01, 0.01);
        },
        completion: { truth in
            self.addNextSceneButton()
        })
    }
    
    func animateInCompass() {
        UIView.animateWithDuration(0.5, animations: {
            self.compass.transform = CGAffineTransformMakeScale(1.0,1.0);
        })
    }
    
    func compassSize() -> CGRect {
        return CGRect(
            x: self.frame.width / 2 - self._ogCompassFrame.width / 2,
            y: self.frame.height - (self._ogCompassFrame.height + 70),
            width: self._ogCompassFrame.width,
            height: self._ogCompassFrame.height
        )
    }
    
    func compassCenter() -> CGRect {
        return CGRect(
            x: frame.width / 2,
            y: frame.height - (70 + _ogCompassFrame.height / 2),
            width: 0,
            height: 0
        )
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
