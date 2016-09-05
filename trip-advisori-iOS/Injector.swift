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
    
    private let _apiAmbassador: AmbassadorToTheAPI
    private let _authService: AuthService
    private let _tripsService: TripsService
    private let _partyService: PartyService
    private let _currentLocationService: CurrentLocationService
    private let _profileService: ProfileService
    private let _loginService: LoginService
    private let _socketService: SocketService
    private let _navigationService: NavigationService

    override init(){
        _authService = AuthService()
        _currentLocationService = CurrentLocationService()
        _profileService = ProfileService()
        _loginService = LoginService(authService: _authService)
        _apiAmbassador = AmbassadorToTheAPI(authService: _authService)
        _tripsService = TripsService(apiAmbassador: _apiAmbassador)
        _partyService = PartyService(apiAmbassador: _apiAmbassador)
        _socketService = SocketService(authService: _authService, currentLocationService: _currentLocationService)
        _navigationService = NavigationService()
        super.init()
    }
    
    func getAuthService() -> AuthService {
        return _authService
    }
    
    func getSocketService() -> SocketService {
        return _socketService
    }
    
    func getLoginService() -> LoginService {
        return _loginService
    }
    
    func getTripsService() -> TripsService {
        return _tripsService
    }
    
    func getProfileService() -> ProfileService {
        return _profileService
    }
    
    func getPartyService() -> PartyService {
        return _partyService
    }
    
    func getCurrentLocationService() -> CurrentLocationService {
        return _currentLocationService
    }
    
    func getNavigationService() -> NavigationService {
        return _navigationService
    }
}
