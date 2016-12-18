import UIKit
import APScheduledLocationManager
import CoreLocation
import Alamofire

class BackgroundLocationManager: Service, APScheduledLocationManagerDelegate {
    fileprivate let configuration = URLSessionConfiguration.background(withIdentifier: "backgound_location_session")
    fileprivate let authService = AuthService()
    
    fileprivate var _backgroundLocationManager: APScheduledLocationManager!
    fileprivate var _sessionManager: SessionManager!
    fileprivate var _headers: (Dictionary<String, String>)!
    
    override init(){
        super.init()
        _backgroundLocationManager = APScheduledLocationManager(delegate: self)
        _backgroundLocationManager.startUpdatingLocation(interval: 5)
        _sessionManager = Alamofire.SessionManager(configuration: configuration)
        
        setHeaders()
    }
    
    func setHeaders() {
        let token = authService.getToken()
        
        _headers = [
            "Authorization": "bearer \(token)"
        ]
    }
    
    func scheduledLocationManager(_ manager: APScheduledLocationManager, didFailWithError error: Error){
        
    }
    
    func scheduledLocationManager(_ manager: APScheduledLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locationObj:CLLocation = locations.last!
        let coord = locationObj.coordinate
        
        let location = [
            "Latitude": coord.latitude,
            "Longitude": coord.longitude
        ]
        _sessionManager.request(apiURL + "/locations", method: .post, parameters: location as [String : AnyObject], encoding: JSONEncoding.default, headers: _headers)
    }
    
    func scheduledLocationManager(_ manager: APScheduledLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
    }

}