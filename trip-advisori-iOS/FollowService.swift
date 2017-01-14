//
//  FollowService.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 10/30/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//

import UIKit

class FollowService: Service {
    private let _apiAmbassador:AmbassadorToTheAPI
    
    init(apiAmbassador: AmbassadorToTheAPI){
        _apiAmbassador = apiAmbassador
    }
    
    func follow(user: User, callback: @escaping () -> Void) {
        _apiAmbassador.post("\(apiURL)/users/\(user.id!)/follow", parameters: ["":"" as AnyObject], success: { response in
            callback()
        })
    }
    
    func unfollow(user: User, callback: @escaping () -> Void) {
        _apiAmbassador.delete("\(apiURL)/users/\(user.id!)/follow", success: { response in
            callback()
        })
    }
    
}
