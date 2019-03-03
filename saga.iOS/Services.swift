//
//  Services.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 4/29/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//

import UIKit

class Services: NSObject {
    static let shared: Services = Services()
    
    private let _apiAmbassador: AmbassadorToTheAPI
    private let _authService: AuthService
    private let _currentLocationService: CurrentLocationService
    private let _facebookService: FacebookService
    private let _loginService: LoginService
    private let _navigationService: NavigationService
    private let _userService: UserService
    private let _searchService: SearchService
    private let _followService: FollowService
    private let _awsService: AwsService
    private let _postService: PostService
    private let _feedService: FeedService
    private let _googleMapsService: GoogleMapsService
    private let _notificationService: NotificationService
    private let _twitterService: TwitterService
    private let _discoveryService: DiscoveryService
    private let _questService: QuestService
    
    override init(){
        _authService = AuthService()
        _notificationService = NotificationService()
        _facebookService = FacebookService()
        _apiAmbassador = AmbassadorToTheAPI(authService: _authService)
        _loginService = LoginService(authService: _authService, notificationService: _notificationService, apiAmbassador: _apiAmbassador)
        _questService = QuestService(apiAmbassador: _apiAmbassador)
        _currentLocationService = CurrentLocationService(apiAmbassador: _apiAmbassador)
        _searchService = SearchService(apiAmbassador: _apiAmbassador)
        _followService = FollowService(apiAmbassador: _apiAmbassador)
        _userService = UserService(apiAmbassador: _apiAmbassador, followService: _followService, facebookService: _facebookService, loginService: _loginService)
        _navigationService = NavigationService()
        _awsService = AwsService(apiAmbassador: _apiAmbassador, currentLocationService:_currentLocationService)
        _postService = PostService(awsService: _awsService, apiAmbassador: _apiAmbassador, currentLocationService: _currentLocationService)
        _feedService = FeedService(apiAmbassador: _apiAmbassador, currentLocationService: _currentLocationService)
        _googleMapsService = GoogleMapsService()
        _twitterService = TwitterService(apiAmbassador: _apiAmbassador)
        _discoveryService = DiscoveryService(apiAmbassador: _apiAmbassador, currentLocationService: _currentLocationService, navigationService: _navigationService)
        
        super.init()
    }
    
    func getDiscoveryService() -> DiscoveryService {
        return _discoveryService
    }
    
    func getTwitterService() -> TwitterService {
        return _twitterService
    }
    
    func getNotificationService() -> NotificationService {
        return _notificationService
    }
    
    func getGoogleMapsService() -> GoogleMapsService {
        return _googleMapsService
    }

    func getFeedService() -> FeedService {
        return _feedService
    }
    
    func getAuthService() -> AuthService {
        return _authService
    }
    
    func getFollowService() -> FollowService {
        return _followService
    }
    
    func getPostService() -> PostService {
        return _postService
    }
    
    func getAwsService() -> AwsService {
        return _awsService
    }
    
    func getSearchService() -> SearchService {
        return _searchService
    }
    
    func getUserService() -> UserService {
        return _userService
    }

    func getLoginService() -> LoginService {
        return _loginService
    }
    
    func getQuestService() -> QuestService {
        return _questService
    }
    
    func getFacebookService() -> FacebookService {
        return _facebookService
    }
    
    func getCurrentLocationService() -> CurrentLocationService {
        return _currentLocationService
    }
    
    func getNavigationService() -> NavigationService {
        return _navigationService
    }
}
