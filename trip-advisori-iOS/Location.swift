import UIKit
import ObjectMapper
import CoreLocation

class Location: NSObject, Mappable {
    var longitude:Double?
    var latitude:Double?
    
    func mapping(map: Map) {
        latitude    <- map["Latitude"]
        longitude   <- map["Longitude"]
    }
    
    required init?(map: Map) {
        
    }
    
    init(longitude: Double, latitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
    
    var cllocation: CLLocation {
        get {
            return CLLocation(latitude: self.latitude ?? 0.0, longitude: self.longitude ?? 0.0)
        }
    }
    
    var queryParam: String {
        get {
            return "\(self.latitude!),\(self.longitude!)|"
        }
    }
}
