import UIKit
import CoreLocation

protocol LocationInfo{
    
    var locationStatus:String { get }
    var longitude:Double { get }
    var latitude:Double { get }
    
}

protocol CurrentLocationServiceDelegate {
    func onLocationUpdated() -> Void
    func onHeadingUpdated() -> Void
}

class CurrentLocationService: NSObject, CLLocationManagerDelegate, LocationInfo {
    
    fileprivate var locationManager:CLLocationManager
    fileprivate var _locationStatus:(code: Int, message: String)
    fileprivate var _longitude:Double
    fileprivate var _latitude:Double
    fileprivate var _course:Double
    fileprivate var _heading:Double
    
    var delegates:[CurrentLocationServiceDelegate] = [CurrentLocationServiceDelegate]()
    var hasRecievedLocation:Bool = false
    
    override init (){
        
        self.locationManager = CLLocationManager()
        
        self._locationStatus = (code: 0, message: "")
        self._longitude = 50.0
        self._latitude = 50.0
        self._course = 0.0
        self._heading = 0.0
        
        super.init()
        
        locationManager.delegate = self
        
        locationManager.requestAlwaysAuthorization()
        locationManager.requestLocation()
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.distanceFilter = 10.00
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        hasRecievedLocation = true
        
        let newLocation = locations.last!
        let coord = newLocation.coordinate
        
        var validLocation = true

        if (locations.count > 1) {
            let oldLocation = locations.secondLast
            validLocation = isValidLocation(newLocation: newLocation, oldLocation: oldLocation)
        }
        
        if (validLocation) {
            _latitude = coord.latitude
            _longitude = coord.longitude
            _course = newLocation.course
            
            for delegate in delegates {
                delegate.onLocationUpdated()
            }
        }
    }
    
    func isValidLocation(newLocation: CLLocation, oldLocation: CLLocation) -> Bool {
        
        if (newLocation.horizontalAccuracy < 0) {
            return false
        }
        
        if (newLocation.horizontalAccuracy > 50) {
            return false
        }
        
        if (oldLocation.coordinate.latitude > 90
            && oldLocation.coordinate.latitude < -90
            && oldLocation.coordinate.longitude > 180
            && oldLocation.coordinate.longitude < -180) {
            return false
        }
        
        if (newLocation.coordinate.latitude > 90
            || newLocation.coordinate.latitude < -90
            || newLocation.coordinate.longitude > 180
            || newLocation.coordinate.longitude < -180) {
            return false
        }
        
        let eventDate = newLocation.timestamp;
        let eventinterval = eventDate.timeIntervalSinceNow;
        
        
        if (abs(eventinterval) < 30.0) {
            return false
        }
        
        if (newLocation.horizontalAccuracy >= 0 && newLocation.horizontalAccuracy < 20) {
            return false
        }
        
        return true
    }
    
    func registerDelegate(_ delegate: CurrentLocationServiceDelegate) {
        delegates.append(delegate)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading ) {
        if (newHeading.headingAccuracy < 0) {
            return
        }

        let theHeading = (newHeading.trueHeading > 0) ? newHeading.trueHeading : newHeading.magneticHeading
        self._heading = theHeading
        
        for delegate in delegates {
            delegate.onHeadingUpdated()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
            
        case CLAuthorizationStatus.restricted:
            _locationStatus = (code: 1, message: "Restricted access to location")
            
        case CLAuthorizationStatus.denied:
            _locationStatus = (code: 0, message: "User denied access to location")
            
        case CLAuthorizationStatus.notDetermined:
            _locationStatus = (code: 0, message: "Status not determined")
            
        default:
            _locationStatus = (code: 1, message: "Allowed to location Access")
            
        }
    }
    
    var locationStatus:String {

        get {

            return _locationStatus.message

        }

    }

    var latitude:Double {

        get {

            return _latitude

        }

    }

    var longitude:Double {

        get {

            return _longitude

        }

    }

    var course:Double {

        get {

            return _course

        }

    }
    
    var heading:Double {
        
        get {
            
            return _heading
            
        }
        
    }

    var location:Location {
        get {
            return Location(longitude: _longitude, latitude: _latitude)
        }
    }
}
