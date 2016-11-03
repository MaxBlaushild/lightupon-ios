import UIKit
import ObjectMapper

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
    
    var queryParam: String {
        get {
            return "\(self.latitude!),\(self.longitude!)|"
        }
    }
}
