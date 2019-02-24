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
    func openCards() -> Void
}

class CompassView: UIView, GMSMapViewDelegate, CurrentLocationServiceDelegate {
    
    fileprivate let currentLocationService = Services.shared.getCurrentLocationService()
    fileprivate let navigationService = Services.shared.getNavigationService()
    
    @IBOutlet weak var sceneMapView: LightuponGMSMapView!
    @IBOutlet weak var compass: UIImageView!
    @IBOutlet weak var instructionsView: UIView!
    @IBOutlet weak var instructionsLabel: UILabel!
    var nextSceneButton: UIButton!
    
    internal var delegate: CompassViewDelegate!
    
    fileprivate var _nextScene: Scene!
    fileprivate var _isAtNextScene: Bool = false
    fileprivate var _ogCompassFrame: CGRect!
    fileprivate var _readyToReceiveResponses: Bool = false
    
    func pointCompassTowardScene(_ nextScene: Scene) {
        _nextScene = nextScene
        
        sceneMapView.delegate = self
        currentLocationService.registerDelegate(self)
        
        setCompassSize()
        centerMapOnLocation()
        configureMapView()
        twirlCompass()
        bindTitleToInstructions()
        addNextScene()
        applyInstructionsView()
        createNextSceneButton()
        
        sceneMapView.bringSubview(toFront: compass)
    }
    
    func setCompassSize() {
        _ogCompassFrame = compass.frame
    }
    
    func configureMapView() {
        sceneMapView.isMyLocationEnabled = true
    }
    
    func applyInstructionsView() {
        instructionsView.addShadow()
        sceneMapView.bringSubview(toFront: instructionsView)
    }
    
    func createCenteredCameraPostion() -> GMSCameraPosition {
        return GMSCameraPosition.camera(
            withLatitude: currentLocationService.latitude,
            longitude: currentLocationService.longitude,
            zoom: 17,
            bearing: currentLocationService.heading,
            viewingAngle: 0
        )
    }
    
    func onNextSceneAvailableUpdated(_ nextSceneAvailable: Bool) {
        if (nextSceneAvailable != _isAtNextScene) {
            if (nextSceneAvailable) {
                _isAtNextScene = nextSceneAvailable
                animateOutCompass()
                checkInTextBoxState()
            } else {
                _isAtNextScene = nextSceneAvailable
                animateOutNextSceneButton()
                undoCheckInTextBoxState()
            }
        }

    }
    
    func bindTitleToInstructions() {
        let instructions = "Follow the arrow until you arrive at \(_nextScene!.name)."
        instructionsLabel.text = instructions
    }
    
    func centerMapOnLocation() {
        let newCenter = self.createCenteredCameraPostion()
        sceneMapView.animate(to: newCenter)
    }
    
    func addNextScene() {
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2DMake(_nextScene!.latitude, _nextScene!.longitude)
        marker.title = "fuck"
        marker.snippet = "fuck"
        marker.map = sceneMapView
    }
    
    func onLocationUpdated() {
        twirlCompass()
    }
    
    func createNextSceneButton() {
        nextSceneButton = UIButton(type: .custom)
        nextSceneButton.addTarget(delegate, action: #selector(delegate.openCards), for: .touchUpInside)
        addSubview(nextSceneButton)
    }
    
    func animateInNextSceneButton() {
        nextSceneButton.frame = compassCenter()
        UIView.animate(withDuration: 0.5, animations: {
            self.nextSceneButton.frame = self.compassSize()
            self.nextSceneButton.layer.cornerRadius = 0.5 * self.nextSceneButton.bounds.size.width
            self.nextSceneButton.backgroundColor = UIColor.white
            self.nextSceneButton.addShadow()
        })
    }
    
    func animateOutNextSceneButton() {
        UIView.animate(withDuration: 0.5, animations: {
            self.nextSceneButton.frame = self.compassCenter()
        },
        completion: animateInCompass)
    }
    
    func animateOutCompass() {
        UIView.animate(withDuration: 0.5, animations: {
            self.compass.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        },
        completion: { truth in
            self.compass.isHidden = true
            self.animateInNextSceneButton()
        })
    }
    
    func animateInCompass(_ truth: Bool) {
        self.compass.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        self.compass.isHidden = false
        UIView.animate(withDuration: 0.5, animations: {
            self.compass.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        },
        completion: { truth in
            self.compass.transform = CGAffineTransform.identity
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
    
    func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }

    
    func checkInTextBoxState() {
        UIView.animate(withDuration: 0.5, animations: {
            self.instructionsView.backgroundColor = UIColor.basePurple
            self.instructionsLabel.textColor = UIColor.white
            self.instructionsLabel.text = "Check it out!"
            self.instructionsLabel.font = self.instructionsLabel.font.withSize(34)
            self.instructionsLabel.textAlignment = NSTextAlignment.center
        })
    }
    
    func undoCheckInTextBoxState() {
        UIView.animate(withDuration: 0.5, animations: {
            self.instructionsView.backgroundColor = UIColor.white
            self.instructionsLabel.textColor = UIColor.black
            self.bindTitleToInstructions()
            self.instructionsLabel.textAlignment = NSTextAlignment.left
            self.instructionsLabel.font = self.instructionsLabel.font.withSize(16)
        })
    }
    
    func onHeadingUpdated() {
        twirlCompass()
    }
    
    func twirlCompass() {
        let origin = CLLocation(latitude: currentLocationService.latitude, longitude: currentLocationService.longitude)
        let destination = CLLocation(latitude: _nextScene!.latitude, longitude: _nextScene!.longitude)
        let bearing = navigationService.getBearingBetweenTwoPoints1(origin, point2: destination)
        var rotationAngle = navigationService.adjustBearingForDeviceHeading(bearing, heading: currentLocationService.heading)
        let otherRotationAngle = rotationAngle * CGFloat(M_PI) / 180
        print("Rotation Angle")
        print(rotationAngle)
//        compass.transform = CGAffineTransform(rotationAngle: rotationAngle)
        var xPosition = sin(rotationAngle) / 2 + 0.5
        var yPosition = cos(rotationAngle) / 2 + 0.5
        UIView.animate(withDuration: 0.25, animations: {
//            if (rotationAngle > 0 && rotationAngle < 45) || (rotationAngle > 315 && rotationAngle < 360) {
//                yPosition = 0
//                if (315 < rotationAngle && rotationAngle < 360) {
//                    rotationAngle = rotationAngle - 360
//                }
//                xPosition = (rotationAngle + 45) / 90
//            } else if (45 < rotationAngle && rotationAngle < 135) {
//                xPosition = 1
//                yPosition = ((rotationAngle - 45) / 90)
//            } else if (135 < rotationAngle && rotationAngle < 225) {
//                yPosition = 1
//                xPosition = ((135 - rotationAngle) / 90) + 1
//            } else if (225 < rotationAngle && rotationAngle < 315) {
//                xPosition = 0
//                yPosition = (225 - rotationAngle) / 90 + 1
//            }
//            
//            xPosition = 0.1 + (4/5) * xPosition
//            yPosition = 0.1 + (4/5) * yPosition
//
//            self.compass.center.x = xPosition * self.frame.width
//            self.compass.center.y = yPosition * self.frame.height
            let offset = CGFloat(5)
            
            let a1 = CGFloat(45) - offset
            let a2 = CGFloat(135) + offset
            let a3 = CGFloat(225) - offset
            let a4 = CGFloat(315) + offset
            
            if (rotationAngle > 0 && rotationAngle < a1) || (rotationAngle > a4 && rotationAngle < 360) {
                yPosition = 0
                if (a4 < rotationAngle && rotationAngle < 360) {
                    rotationAngle = rotationAngle - 360
                }
                xPosition = (rotationAngle + a1) / (90 - 2 * offset)
            } else if (a1 < rotationAngle && rotationAngle < a2) {
                xPosition = 1
                yPosition = ((rotationAngle - a1) / (90 + 2 * offset))
            } else if (a2 < rotationAngle && rotationAngle < a3) {
                yPosition = 1
                xPosition = ((a2 - rotationAngle) / (90 - 2 * offset)) + 1
            } else if (a3 < rotationAngle && rotationAngle < a4) {
                xPosition = 0
                yPosition = (a3 - rotationAngle) / (90 + 2 * offset) + 1
            }
            
            xPosition = 0.1 + (4/5) * xPosition
            yPosition = 0.1 + (4/5) * yPosition
            self.compass.center.x = xPosition * self.frame.width
            self.compass.center.y = yPosition * self.frame.height
            self.compass.transform = CGAffineTransform(rotationAngle: otherRotationAngle)
        })
    }

}
