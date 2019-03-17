//
//  Compass.swift
//  Lightupon
//
//  Created by Blaushild, Max on 3/31/17.
//  Copyright © 2017 Blaushild, Max. All rights reserved.
//

import UIKit
import Foundation
import GoogleMaps

class Compass: UIView, CurrentLocationServiceDelegate {

    private let navigationService = Services.shared.getNavigationService()
    private let currentLocationService = Services.shared.getCurrentLocationService()

    var target: CLLocation?
    
    func onHeadingUpdated() {
        twirl()
    }
    
    func onLocationUpdated() {}
    
    func pointTowards(target: CLLocation) {
        self.target = target
        currentLocationService.registerDelegate(self)
    }
    
    func twirl() {
        if let destination = target {
            let origin = CLLocation(latitude: currentLocationService.latitude, longitude: currentLocationService.longitude)
            let bearing = navigationService.getBearingBetweenTwoPoints1(origin, point2: destination)
            var rotationAngle = navigationService.adjustBearingForDeviceHeading(bearing, heading: currentLocationService.heading)
            let otherRotationAngle = rotationAngle * CGFloat(M_PI) / 180
            var xPosition = sin(rotationAngle) / 2 + 0.5
            var yPosition = cos(rotationAngle) / 2 + 0.5
            UIView.animate(withDuration: 0.25, animations: {

                // aspect ration
                let a: CGFloat = 0.56
                // map rotation offset
                let b: CGFloat = 0.45


                let beta1 = atan( (1 + 2 * b) / a ) * 180 / CGFloat(M_PI)
                let beta2 = atan( (1 - 2 * b) / a ) * 180 / CGFloat(M_PI)

                let a1 = CGFloat(90 - beta1)
                let a2 = CGFloat(90 + beta2)
                let a3 = CGFloat(270 - beta2)
                let a4 = CGFloat(270 + beta1)
                
                if (rotationAngle < 0 ) {
                    rotationAngle = rotationAngle + 360
                }

                if (rotationAngle > 0 && rotationAngle < a1) || (rotationAngle > a4 && rotationAngle < 360) {
                    yPosition = 0
                    if (a4 < rotationAngle && rotationAngle < 360) {
                        rotationAngle = rotationAngle - 360
                    }
                    xPosition = (rotationAngle + a1) / (a1 * 2)
                } else if (a1 < rotationAngle && rotationAngle < a2) {
                    xPosition = 1
                    yPosition = 1 - (0.5 - b + (a/2) * tan((90.00 - rotationAngle) * CGFloat(M_PI) / 180))
                } else if (a2 < rotationAngle && rotationAngle < a3) {
                    yPosition = 1
                    xPosition = 1 - ((rotationAngle - a2) / (a3 - a2))
                } else if (a3 < rotationAngle && rotationAngle < a4) {
                    xPosition = 0
                    yPosition = 1 - (0.5 - b + (a/2)*tan((rotationAngle - 270.00) * CGFloat(M_PI) / 180))
                }
                
                let screenSize: CGRect = UIScreen.main.bounds
                xPosition = 0.1 + (4/5) * xPosition
                yPosition = 0.15 + (7/10) * yPosition
                self.center.x = xPosition * screenSize.width
                self.center.y = yPosition * screenSize.height
                self.transform = CGAffineTransform(rotationAngle: otherRotationAngle)
            })
        }
    }
}
