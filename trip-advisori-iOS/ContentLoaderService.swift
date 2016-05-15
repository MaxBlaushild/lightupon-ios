//
//  ContentLoaderService.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 4/29/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//

import UIKit

class ContentLoaderService: Service {
    private var authService: AuthService!
    private var partyService: PartyService!
    private var loggedIn: Bool = false
    
    init(_authService_: AuthService, _partyService_: PartyService){
        authService = _authService_
        partyService = _partyService_
    }
    
    func loadContent(callback: (String) -> Void) {
        loggedIn = authService.userIsLoggedIn()
        
        if (loggedIn) {
            checkIfUserIsInParty(callback)
        } else {
           callback("InitialToLogin")
        }
    }
    
    func checkIfUserIsInParty(callback: (String) -> Void){
        partyService.isUserInParty(callback)
    }
}
