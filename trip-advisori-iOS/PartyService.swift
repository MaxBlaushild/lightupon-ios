//
//  JoinPartyAPIController.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 3/25/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//

import UIKit
import SwiftyJSON

class PartyService: Service {
    var apiAmbassador:AmbassadorToTheAPI!
    
    init(_apiAmbassador_: AmbassadorToTheAPI){
        apiAmbassador = _apiAmbassador_
    }
    
    func joinParty(passcode: String, callback: () -> Void) {
        let parameters = [
            "": ""
        ]
        
        apiAmbassador.post(apiURL + "/parties/\(passcode)/users", parameters: parameters, success: { request, response, result in
            
            callback()
            
        })
    }
    
    func getUsersParty(callback: (Party) -> Void) {
        apiAmbassador.get(apiURL + "/parties", success: { request, response, result in
            let json = JSON(result!.value!)
            
            let party:Party = Party(json: json)
            
            callback(party)
            
        })
    }
    
    func startNextScene(partyID: Int) {
        apiAmbassador.get(apiURL + "/parties/\(partyID)/nextScene", success: { request, response, result in
            
        })
    }
    
    func leaveParty(partyID: Int, callback: () -> Void) {
        apiAmbassador.get(apiURL + "/parties/\(partyID)/leave", success: { request, response, result in
            
            callback()
        })
    }

    
    func isUserInParty(callback: (String) -> Void) {
        apiAmbassador.get(apiURL + "/parties", success: { request, response, result in
            let json = JSON(result!.value!)
            
            let party:Party = Party(json: json)
            
            let segue: String = party.id == 0 ? "LoadingToTabs" : "InitialToLobby"
            
            callback(segue)
        })
    }
    
    func createParty(tripId: Int, callback: () -> Void) {
        let parameters = [
            "ID": tripId
        ]
        
        apiAmbassador.post(apiURL + "/parties", parameters: parameters, success: { request, response, result in
            
            callback()
            
        })
    }
}
