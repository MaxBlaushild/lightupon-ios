//
//  LikeService.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 1/12/17.
//  Copyright © 2017 Blaushild, Max. All rights reserved.
//

import UIKit
import ObjectMapper

class LikeService: NSObject {
    fileprivate let _apiAmbassador: AmbassadorToTheAPI
    
    init(apiAmbassador: AmbassadorToTheAPI) {
        _apiAmbassador = apiAmbassador
    }
    
    func likeScene(scene: Scene, success: @escaping () -> Void) {
        let parameters = [ "": "" ]
        _apiAmbassador.post("/scenes/\(scene.id!)/likes", parameters: parameters as [String : AnyObject] , success: { response in
            success()
        })
    }
    
    func unlikeScene(scene: Scene, success: @escaping () -> Void) {
        _apiAmbassador.delete("/scenes/\(scene.id!)/likes", success: { response in
            success()
        })
    }
}
