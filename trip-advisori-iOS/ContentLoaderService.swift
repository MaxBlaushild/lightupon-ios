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
    private var profileService: ProfileService!
    private var loggedIn: Bool = false
    private var contentLoadedCallback: (String) -> Void
    
    init(_authService_: AuthService, _partyService_: PartyService, _profileService_: ProfileService){
        authService = _authService_
        partyService = _partyService_
        profileService = _profileService_
        contentLoadedCallback = { _ in }
    }
    
    func loadContent(callback: (String) -> Void) {
        loggedIn = authService.userIsLoggedIn()
        contentLoadedCallback = callback
        
        if (loggedIn) {
            profileService.getMyProfile(self.checkIfUserIsInParty)
        } else {
           callback("InitialToLogin")
        }
    }
    
    func checkIfUserIsInParty(_: FacebookProfile) {
        partyService.isUserInParty(self.contentLoadedCallback)
    }
}
