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
    let apiAmbassador:AmbassadorToTheAPI
    
    private var _currentParty_: Party!
    
    init(_apiAmbassador_: AmbassadorToTheAPI){
        apiAmbassador = _apiAmbassador_
    }
    
    func joinParty(passcode: String, successCallback: () -> Void, failureCallback: () -> Void) {
        let parameters = [
            "": ""
        ]
        
        apiAmbassador.post(apiURL + "/parties/\(passcode)/users", parameters: parameters, success: { response in
            if (response.response!.statusCode == 200) {
                successCallback()
            } else {
                failureCallback()
            }
        })
    }
    
    func getUsersParty(callback: (Party) -> Void) {
        apiAmbassador.get(apiURL + "/parties", success: { response in
            let party = Mapper<Party>().map(response.result.value)
            callback(party!)
            
        })
    }
    
    func startNextScene(partyID: Int) {
        apiAmbassador.get(apiURL + "/parties/\(partyID)/nextScene", success: { response in
            
        })
    }
    
    func leaveParty(callback: () -> Void) {
        apiAmbassador.delete(apiURL + "/parties", success: { response in
            callback()
        })
    }
    
    func createParty(tripId: Int, callback: (Party) -> Void) {
        let parameters = [
            "ID": tripId
        ]
        
        apiAmbassador.post(apiURL + "/parties", parameters: parameters, success: { response in
            let party = Mapper<Party>().map(response.result.value)
            callback(party!)
        })
    }
}
