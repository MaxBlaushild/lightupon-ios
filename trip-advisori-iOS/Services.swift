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
    private let _tripsService: TripsService
    private let _partyService: PartyService
    private let _currentLocationService: CurrentLocationService
    private let _facebookService: FacebookService
    private let _loginService: LoginService
    private let _socketService: SocketService
    private let _navigationService: NavigationService
    private let _litService: LitService
    private let _userService: UserService
    private let _searchService: SearchService
    private let _followService: FollowService
    private let _awsService: AwsService
    private let _postService: PostService
    private let _feedService: FeedService
    private let _commentService: CommentService
    private let _likeService: LikeService
    private let _googleMapsService: GoogleMapsService
    private let _notificationService: NotificationService

    override init(){
        _authService = AuthService()
        _notificationService = NotificationService()
        _facebookService = FacebookService()
        _loginService = LoginService(authService: _authService, notificationService: _notificationService)
        _apiAmbassador = AmbassadorToTheAPI(authService: _authService)
        _tripsService = TripsService(apiAmbassador: _apiAmbassador)
        _currentLocationService = CurrentLocationService(tripsService: _tripsService)
        _litService = LitService(apiAmbassador: _apiAmbassador, currentLocationService: _currentLocationService)
        _searchService = SearchService(apiAmbassador: _apiAmbassador)
        _followService = FollowService(apiAmbassador: _apiAmbassador)
        _userService = UserService(apiAmbassador: _apiAmbassador, litService: _litService, followService: _followService)
        _socketService = SocketService(authService: _authService, currentLocationService: _currentLocationService)
        _partyService = PartyService(apiAmbassador: _apiAmbassador, socketService: _socketService)
        _navigationService = NavigationService()
        _awsService = AwsService(apiAmbassador: _apiAmbassador, currentLocationService:_currentLocationService)
        _postService = PostService(awsService: _awsService, apiAmbassador: _apiAmbassador, litService: _litService, currentLocationService: _currentLocationService)
        _feedService = FeedService(apiAmbassador: _apiAmbassador, currentLocationService: _currentLocationService)
        _commentService = CommentService(apiAmbassador: _apiAmbassador)
        _likeService = LikeService(apiAmbassador: _apiAmbassador)
        _googleMapsService = GoogleMapsService()
        super.init()
    }
    
    func getNotificationService() -> NotificationService {
        return _notificationService
    }
    
    func getGoogleMapsService() -> GoogleMapsService {
        return _googleMapsService
    }
    
    func getLikeService() -> LikeService {
        return _likeService
    }
    
    func getCommentService() -> CommentService {
        return _commentService
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
    
    func getLitService() -> LitService {
        return _litService
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
    
    func getFacebookService() -> FacebookService {
        return _facebookService
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
