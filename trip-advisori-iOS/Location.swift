import UIKit
import ObjectMapper

class Location: NSObject, Mappable {
    var longitude:Double?
    var latitude:Double?
    
    func mapping(map: Map) {
        latitude    <- map["Latitude"]
        longitude   <- map["Longitude"]
    }
    
    required init?(_ map: Map) {
        
    }
    
    init(longitude: Double, latitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
}
