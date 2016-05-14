//
//  Injector.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 4/29/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//

import UIKit

class Injector: Service {
    static let sharedInjector: Injector = Injector()
    
    private var apiAmbassador: AmbassadorToTheAPI!
    private var authService: AuthService!
    private var contentLoaderService: ContentLoaderService!
    private var tripsService: TripsService!
    private var partyService: PartyService!
    private var currentLocationService: CurrentLocationService!
    private var profileService: ProfileService!
    private var loginService: LoginService!
    private var socketService: SocketService!
    private var alertService: AlertService!

    override init(){
        super.init()
        instantiateServices()
    }
    
    func instantiateServices() {
        authService = AuthService()
        currentLocationService = CurrentLocationService()
        profileService = ProfileService()
        alertService = AlertService()
        loginService = LoginService(_authService_: authService)
        apiAmbassador = AmbassadorToTheAPI(_authService_: authService)
        tripsService = TripsService(_apiAmbassador_: apiAmbassador)
        partyService = PartyService(_apiAmbassador_: apiAmbassador)
        contentLoaderService = ContentLoaderService(_authService_: authService, _partyService_: partyService)
        socketService = SocketService(_authService_: authService, _currentLocation_: currentLocationService)
    }
    
    func getAuthService() -> AuthService {
        return authService
    }
    
    func getContentLoaderService() -> ContentLoaderService {
        return contentLoaderService
    }
    
    func getSocketService() -> SocketService {
        return socketService
    }
    
    func getLoginService() -> LoginService {
        return loginService
    }
    
    func getTripsService() -> TripsService {
        return tripsService
    }
    
    func getProfileService() -> ProfileService {
        return profileService
    }
    
    func getPartyService() -> PartyService {
        return partyService
    }
    
    func getCurrentLocationService() -> CurrentLocationService {
        return currentLocationService
    }
    
    func getAlertService() -> AlertService {
        return alertService
    }
}
