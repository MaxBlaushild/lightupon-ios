import UIKit
import CoreLocation
import APScheduledLocationManager

protocol LocationInfo{
    var locationStatus:String { get }
    var longitude:Double { get }
    var latitude:Double { get }
}

@objc protocol CurrentLocationServiceDelegate {
    func onLocationUpdated() -> Void
    @objc optional func onHeadingUpdated() -> Void
}

class CurrentLocationService: NSObject, CLLocationManagerDelegate, LocationInfo {
    
    
    fileprivate var _locationManager:CLLocationManager
    fileprivate var _locationStatus:(code: Int, message: String)
    fileprivate var _longitude:Double
    fileprivate var _latitude:Double
    fileprivate var _course:Double
    fileprivate var _heading:Double
    fileprivate var _lastLocationDate:NSDate = NSDate()
    
    let tripsService:TripsService
    let apiAmbassador:AmbassadorToTheAPI
    
    var delegates:[CurrentLocationServiceDelegate] = [CurrentLocationServiceDelegate]()
    
    init(tripsService: TripsService, apiAmbassador: AmbassadorToTheAPI){
        
        self.tripsService = tripsService
        self.apiAmbassador = apiAmbassador
        self._locationManager = CLLocationManager()

        self._locationStatus = (code: 0, message: "")
        self._longitude = 50.0
        self._latitude = 50.0
        self._course = 0.0
        self._heading = 0.0
        
        super.init()
        
        _locationManager.delegate = self
        
        if (CLLocationManager.authorizationStatus() != .authorizedAlways) {
            _locationManager.requestAlwaysAuthorization()
        }
        
        _locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        _locationManager.distanceFilter = 10.00
        _locationManager.startUpdatingHeading()
        _locationManager.startUpdatingLocation()
    }
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        _locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locationObj:CLLocation = locations.last!
        let coord = locationObj.coordinate
    
        _latitude = coord.latitude
        _longitude = coord.longitude
        _course = locationObj.course
            
        for delegate in delegates {
            delegate.onLocationUpdated()
        }
    }
    
    func updateLocation() {
        let location = [
            "Latitude": _latitude,
            "Longitude": _longitude
            ] as [String : Any]
        
        apiAmbassador.post("/discover", parameters: location as [String : AnyObject], success: { _ in
        }, failure: { _ in })
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
            if let _ = delegate.onHeadingUpdated?() {}
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
    
    var cllocation: CLLocation {
        get {
            return CLLocation(latitude: _latitude, longitude: _longitude)
        }
    }
    
    var locationStatus: String {
        get {
            return _locationStatus.message
        }
    }

    var latitude: Double {
        get {
            return _latitude
        }
    }

    var longitude: Double {
        get {
            return _longitude
        }
    }

    var course: Double {
        get {
            return _course
        }
    }
    
    var heading: Double {
        get {
            return _heading
        }
    }

    var location: Location {
        get {
            return Location(longitude: _longitude, latitude: _latitude)
        }
    }
}
