//
//  FeedService.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 12/19/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//

import UIKit
import ObjectMapper

class FeedService: Service {
    fileprivate let _apiAmbassador: AmbassadorToTheAPI
    
    init(apiAmbassador: AmbassadorToTheAPI) {
        _apiAmbassador = apiAmbassador
    }
    
    func getFeed(success: @escaping ([Scene]) -> Void) {
        _apiAmbassador.get("\(apiURL)/scenes", success: { response in
            let scenes = Mapper<Scene>().mapArray(JSONObject: response.result.value)
            success(scenes!)
        })
    }

}
