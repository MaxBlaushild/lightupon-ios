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
    
    private var _follows: [Follow] = [Follow]()
    
    init(apiAmbassador: AmbassadorToTheAPI){
        _apiAmbassador = apiAmbassador
    }
    
    func follow(user: User, callback: @escaping () -> Void) {
        _apiAmbassador.post("\(apiURL)/users/\(user.id!)/follow", parameters: ["":"" as AnyObject], success: { response in
            self.addFollow(user: user)
            callback()
        })
    }
    
    func unfollow(user: User, callback: @escaping () -> Void) {
        _apiAmbassador.delete("\(apiURL)/users/\(user.id!)/follow", success: { response in
            self.removeFollow(user: user)
            callback()
        })
    }
    
    func isFollowing(user: User) -> Bool {
        var isFollowing = false
        for follow in _follows {
            if user.id == follow.followedUserID {
                isFollowing = true
            }
        }
        return isFollowing
    }
    
    func setFollows(follows: [Follow]) {
        _follows = follows
    }
    
    func addFollow(user: User) {
        let newFollow = Follow(user: user)
        _follows.append(newFollow)
    }
    
    func removeFollow(user: User) {
        for (index, follow) in _follows.enumerated() {
            if user.id == follow.followedUserID {
                _follows.remove(at: index)
            }
        }
    }
    
}
