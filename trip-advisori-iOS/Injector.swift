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
    
    fileprivate let _apiAmbassador: AmbassadorToTheAPI
    fileprivate let _authService: AuthService
    fileprivate let _tripsService: TripsService
    fileprivate let _partyService: PartyService
    fileprivate let _currentLocationService: CurrentLocationService
    fileprivate let _profileService: ProfileService
    fileprivate let _loginService: LoginService
    fileprivate let _socketService: SocketService
    fileprivate let _navigationService: NavigationService

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
