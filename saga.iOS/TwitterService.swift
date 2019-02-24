//
//  TwitterService.swift
//  Lightupon
//
//  Created by Blaushild, Max on 5/28/17.
//  Copyright © 2017 Blaushild, Max. All rights reserved.
//

import UIKit
import TwitterKit

class TwitterService: NSObject {
    
    private let _apiAmbassador:AmbassadorToTheAPI
    
    init(apiAmbassador: AmbassadorToTheAPI) {
        _apiAmbassador = apiAmbassador
    }
    
    func logIn(_ callback: @escaping () -> Void) {
        TWTRTwitter.sharedInstance().logIn(completion: { session, error in
            if let s = session {
                
                let twitterCreds = [
                    "TwitterKey": s.authToken,
                    "TwitterSecret": s.authTokenSecret
                ]
                
                self._apiAmbassador.post("/me/twitter/login", parameters: twitterCreds as [String : AnyObject], success: { _ in
                    callback()
                })
            }
        })
    }
}

