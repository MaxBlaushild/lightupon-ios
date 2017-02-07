//
//  JoinPartyAPIController.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 3/25/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//

import UIKit
import ObjectMapper

class PartyService: NSObject {
    
    private let _apiAmbassador:AmbassadorToTheAPI
    
    init(apiAmbassador: AmbassadorToTheAPI){
        _apiAmbassador = apiAmbassador
    }
    
    func joinParty(passcode: String, successCallback: @escaping () -> Void, failureCallback: @escaping () -> Void) {
        let parameters = [
            "": ""
        ]
        
        _apiAmbassador.post("/parties/\(passcode)/users", parameters: parameters as [String : AnyObject], success: { response in
            if (response.response!.statusCode == 200) {
                successCallback()
            } else {
                failureCallback()
            }
        })
    }
    
    func startNextScene(partyID: Int, callback: @escaping () -> Void) {
        _apiAmbassador.get("/parties/\(partyID)/nextScene", success: { response in
            callback()
        })
     }
    
    func getUsersParty(_ callback: @escaping (Party) -> Void) {
        _apiAmbassador.get("/parties", success: { response in
            let party = Mapper<Party>().map(JSONObject: response.result.value)
            callback(party!)
        })
    }
    
    func leaveParty(_ callback: @escaping () -> Void) {
        _apiAmbassador.delete("/parties", success: { response in
            callback()
        })
    }
    
    func finishParty(_ callback: @escaping () -> Void) {
        _apiAmbassador.get("/parties/finishParty", success: { response in
            callback()
        })
    }
    
    func createParty(_ tripId: Int, callback: @escaping () -> Void) {
        let parameters = [
            "ID": tripId
        ]
        
        _apiAmbassador.post("/parties", parameters: parameters as [String : AnyObject], success: { response in
            callback()
        })
    }
}
