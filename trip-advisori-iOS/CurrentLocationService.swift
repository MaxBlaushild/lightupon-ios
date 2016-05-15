import UIKit
import CoreLocation

protocol LocationInfo{
    
    var locationStatus:String { get }
    var longitude:Double { get }
    var latitude:Double { get }
    
}

protocol CurrentLocationServiceDelegate {
    func onLocationUpdated() -> Void
}

class CurrentLocationService: NSObject, CLLocationManagerDelegate, LocationInfo {
    
    private var locationManager:CLLocationManager
    private var _locationStatus:(code: Int, message: String)
    private var _longitude:Double
    private var _latitude:Double
    
    internal var delegate: CurrentLocationServiceDelegate!
    
    override init (){
        
        self.locationManager = CLLocationManager()
        
        self._locationStatus = (code: 0, message: "")
        self._longitude = 0.0
        self._latitude = 0.0
        
        super.init()
        
        locationManager.delegate = self
        
        locationManager.requestAlwaysAuthorization()
        locationManager.requestLocation()
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startMonitoringSignificantLocationChanges()
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locationObj:CLLocation = locations.last!
        let coord = locationObj.coordinate
        
        _latitude = coord.latitude
        _longitude = coord.longitude
        
        if delegate != nil {
            delegate.onLocationUpdated()
        }
        
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        switch status {
            
        case CLAuthorizationStatus.Restricted:
            _locationStatus = (code: 1, message: "Restricted access to location")
            
        case CLAuthorizationStatus.Denied:
            _locationStatus = (code: 0, message: "User denied access to location")
            
        case CLAuthorizationStatus.NotDetermined:
            _locationStatus = (code: 0, message: "Status not determined")
            
        default:
            _locationStatus = (code: 1, message: "Allowed to location Access")
            
        }
        
        // TODO: add a notification for the status changed event
        let data:[NSObject: AnyObject] = ["status": DataWrapper(element: _locationStatus)]
        
        NSNotificationCenter.defaultCenter().postNotificationName("updatedLocations",
            object: nil,
            userInfo: data)
        
        
        
    }
    
    // MARK: LocationInfo implementation
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
    
    var location:Location {
        get {
            return Location(longitude: _longitude, latitude: _latitude)
        }
    }
}