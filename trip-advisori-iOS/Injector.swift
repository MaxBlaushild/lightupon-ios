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
        _loginService = LoginService(_authService_: _authService)
        _apiAmbassador = AmbassadorToTheAPI(_authService_: _authService)
        _tripsService = TripsService(_apiAmbassador_: _apiAmbassador)
        _partyService = PartyService(_apiAmbassador_: _apiAmbassador)
        _socketService = SocketService(_authService_: _authService, _currentLocation_: _currentLocationService)
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
