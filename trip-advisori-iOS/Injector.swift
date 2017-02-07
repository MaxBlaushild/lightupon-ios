//
//  Injector.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 4/29/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//

import UIKit

class Injector: NSObject {
    static let sharedInjector: Injector = Injector()
    
    fileprivate let _apiAmbassador: AmbassadorToTheAPI
    fileprivate let _authService: AuthService
    fileprivate let _tripsService: TripsService
    fileprivate let _partyService: PartyService
    fileprivate let _currentLocationService: CurrentLocationService
    fileprivate let _facebookService: FacebookService
    fileprivate let _loginService: LoginService
    fileprivate let _socketService: SocketService
    fileprivate let _navigationService: NavigationService
    fileprivate let _litService: LitService
    fileprivate let _userService: UserService
    fileprivate let _searchService: SearchService
    fileprivate let _followService: FollowService
    fileprivate let _awsService: AwsService
    fileprivate let _postService: PostService
    fileprivate let _feedService: FeedService
    fileprivate let _commentService: CommentService
    fileprivate let _likeService: LikeService
    fileprivate let _googleMapsService: GoogleMapsService
    fileprivate let _notificationService: NotificationService

    override init(){
        _authService = AuthService()
        _notificationService = NotificationService()
        _facebookService = FacebookService()
        _loginService = LoginService(authService: _authService, notificationService: _notificationService)
        _apiAmbassador = AmbassadorToTheAPI(authService: _authService)
        _tripsService = TripsService(apiAmbassador: _apiAmbassador)
        _partyService = PartyService(apiAmbassador: _apiAmbassador)
        _currentLocationService = CurrentLocationService()
        _litService = LitService(apiAmbassador: _apiAmbassador, currentLocationService: _currentLocationService)
        _searchService = SearchService(apiAmbassador: _apiAmbassador)
        _followService = FollowService(apiAmbassador: _apiAmbassador)
        _userService = UserService(apiAmbassador: _apiAmbassador, litService: _litService, followService: _followService)
        _socketService = SocketService(authService: _authService)
        _navigationService = NavigationService()
        _awsService = AwsService(apiAmbassador: _apiAmbassador, currentLocationService:_currentLocationService)
        _postService = PostService(awsService: _awsService, apiAmbassador: _apiAmbassador, litService: _litService, currentLocationService: _currentLocationService)
        _feedService = FeedService(apiAmbassador: _apiAmbassador)
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
