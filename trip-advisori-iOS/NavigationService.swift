//
//  NavigationService.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 8/28/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//

import UIKit
import GoogleMaps

class NavigationService: Service {
    
    func adjustBearingForDeviceHeading(bearing: CGFloat, heading: Double) -> CGFloat {
        let heading = CGFloat(heading)
        let delta = bearing - heading
        let normalizedDelta = delta + 360
        return normalizedDelta % 360
    }
    
    func degreesToRadians(degrees: Double) -> Double {
        return degrees * M_PI / 180.0
    }
    
    func radiansToDegrees(radians: Double) -> Double {
        return radians * 180.0 / M_PI
    }
    
    func getBearingBetweenTwoPoints1(point1 : CLLocation, point2 : CLLocation) -> CGFloat {
        
        let lat1 = degreesToRadians(point1.coordinate.latitude)
        let lon1 = degreesToRadians(point1.coordinate.longitude)
        
        let lat2 = degreesToRadians(point2.coordinate.latitude);
        let lon2 = degreesToRadians(point2.coordinate.longitude);
        
        let dLon = lon2 - lon1;
        
        let y = sin(dLon) * cos(lat2);
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);
        let radiansBearing = atan2(y, x);
        
        return CGFloat(radiansToDegrees(radiansBearing))
    }
}
