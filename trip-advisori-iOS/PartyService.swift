//
//  JoinPartyAPIController.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 3/25/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//

import UIKit
import SwiftyJSON
import ObjectMapper

class PartyService: Service {
    
    private let _apiAmbassador:AmbassadorToTheAPI
    
    init(_apiAmbassador_: AmbassadorToTheAPI){
        _apiAmbassador = _apiAmbassador_
    }
    
    func joinParty(passcode: String, successCallback: () -> Void, failureCallback: () -> Void) {
        let parameters = [
            "": ""
        ]
        
        _apiAmbassador.post(apiURL + "/parties/\(passcode)/users", parameters: parameters, success: { response in
            if (response.response!.statusCode == 200) {
                successCallback()
            } else {
                failureCallback()
            }
        })
    }
    
    func startNextScene(partyID: Int) {
        _apiAmbassador.get(apiURL + "/parties/\(partyID)/nextScene", success: { response in

        })
     }
    
    func getUsersParty(callback: (Party) -> Void) {
        _apiAmbassador.get(apiURL + "/parties", success: { response in
            let party = Mapper<Party>().map(response.result.value)
            callback(party!)
        })
    }
    
    func leaveParty(callback: () -> Void) {
        _apiAmbassador.delete(apiURL + "/parties", success: { response in
            callback()
        })
    }
    
    func createParty(tripId: Int, callback: (Party) -> Void) {
        let parameters = [
            "ID": tripId
        ]
        
        _apiAmbassador.post(apiURL + "/parties", parameters: parameters, success: { response in
            let party = Mapper<Party>().map(response.result.value)
            callback(party!)
        })
    }
}
