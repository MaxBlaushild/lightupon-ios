//
//  SearchService.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 10/30/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//

import UIKit
import ObjectMapper

class SearchService: NSObject {
    
    private let _apiAmbassador:AmbassadorToTheAPI
    
    init(apiAmbassador: AmbassadorToTheAPI) {
        _apiAmbassador = apiAmbassador
    }
    
    func findUsers(query: String, callback: @escaping ([User]) -> Void) {
        _apiAmbassador.get("/users?full_name=\(query)", success: { response in
            let users =  Mapper<User>().mapArray(JSONObject: response.result.value)
            callback(users!)
        })
    }
}
