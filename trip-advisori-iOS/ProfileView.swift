//
//  ProfileView.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 9/25/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//

import UIKit
import GoogleMaps

protocol ProfileViewDelegate {
    func onLoggedOut() -> Void
}

protocol ProfileViewCreator {
    func createProfileView(user: User)
}

enum ProfileContext {
    case isUser, following, notFollowing, pending
}

enum TabBarContext {
    case lights, map
}

class ProfileView: UIView, UITableViewDelegate, UITableViewDataSource, GMSMapViewDelegate {
    fileprivate let authService = Injector.sharedInjector.getAuthService()
    fileprivate let facebookService = Injector.sharedInjector.getFacebookService()
    fileprivate let userService = Injector.sharedInjector.getUserService()
    fileprivate let followService = Injector.sharedInjector.getFollowService()
    fileprivate let feedService = Injector.sharedInjector.getFeedService()
    fileprivate let tripService = Injector.sharedInjector.getTripsService()
    fileprivate let currentLocationService = Injector.sharedInjector.getCurrentLocationService()

    @IBOutlet weak var tabBar: UIView!
    @IBOutlet weak var actionPackedButton: UIButton!
    @IBOutlet weak var blurImage: UIImageView!
    @IBOutlet weak var circleImage: UIImageView!
    @IBOutlet weak var fullnameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var buttonView: UIView!
    @IBOutlet weak var followerSection: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var lightTab: UIButton!
    @IBOutlet weak var mapTab: UIButton!
    @IBOutlet weak var numberOfFollowersLabel: UILabel!
    @IBOutlet weak var numberOfTripsLabel: UILabel!
    @IBOutlet weak var mapView: LightuponGMSMapView!
    
    fileprivate var profileContext: ProfileContext = ProfileContext.isUser
    fileprivate var tabBarContext: TabBarContext = TabBarContext.lights
    fileprivate var actionPackButtonHandler:(() -> Void)!
    
    fileprivate var _user: User!
    fileprivate var _scenes: [Scene] = [Scene]()
    
    internal var delegate: ProfileViewDelegate!
    
    @IBAction func onActionPackedButtonPress(_ sender: AnyObject) {
        actionPackButtonHandler()
    }
    
    @nonobjc func initializeView(_ user: User) {
        getUser(user.id!)
        tabBar.layer.addBorder(edge: .bottom, color: Colors.mediumGrey, thickness: 1.0)
        configureTableView()
        configureMapView()
        centerMap()
        setTabBar()
        style()
    }
    
    func configureMapView() {
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        mapView.delegate = self
    }
    
    func getUsersTrips() {
        tripService.getUsersTrips(_user.id!, callback: self.onTripsReceived)
    }
    
    func onTripsReceived(trips: [Trip]) {
        mapView.bindTrips(trips)
    }
    
    func centerMap() {
        mapView.camera = GMSCameraPosition.camera(withLatitude: currentLocationService.latitude, longitude: currentLocationService.longitude, zoom: 15)
    }
    
    func getUser(_ userID: Int) {
        userService.getUser(userID, success: self.setUser)
    }
    
    @IBAction func activateLightTab(_ sender: Any) {
        tabBarContext = .lights
        setTabBar()
    }
    
    @IBAction func activateMapTab(_ sender: Any) {
        tabBarContext = .map
        setTabBar()
    }
    
    func setTabBar() {
        resetTabColors()
        hideViews()
        
        switch tabBarContext {
        case .lights:
            setTabBarButtonToActive(lightTab)
            tableView.isHidden = false
        case .map:
            setTabBarButtonToActive(mapTab)
            mapView.isHidden = false
        }
    }
    
    func setTabBarButtonToActive(_ button: UIButton) {
        button.setTitleColor(Colors.basePurple, for: .normal)
    }
    
    func resetTabColors() {
        let tabs = [mapTab, lightTab]
        tabs.forEach({ tab in tab?.titleLabel?.textColor = UIColor.lightGray })
    }
    
    func hideViews() {
        let views = [tableView, mapView] as [UIView]
        views.forEach({ view in view.isHidden = true })
    }

    func getUsersFeed() {
        feedService.getUsersFeed(userID: _user.id!, success: self.onFeedReceived)
    }
    
    func onFeedReceived(scenes: [Scene]) {
        _scenes = scenes
        tableView.reloadData()
    }
    
    func setUser(_ user: User) {
        _user = user
        getUsersFeed()
        getUsersTrips()
        setUserContext(user)
        bindUser(user)
    }
    
    func refresh() {
        getUser(_user.id!)
        centerMap()
    }
    
    func bindUser(_ user: User) {
        circleImage.imageFromUrl(user.profilePictureURL!)
        blurImage.imageFromUrl(user.profilePictureURL!)
        fullnameLabel.text = user.fullName
        numberOfTripsLabel.text = "\(user.numberOfTrips!)"
        numberOfFollowersLabel.text = "\(user.numberOfFollowers!)"
    }
    
    func setUserContext(_ user: User) {
        let isUser = userService.isUser(user.profile)
        let isFollowing = user.following!
        profileContext = isUser ? .isUser : .notFollowing
        profileContext = isFollowing ? .following : profileContext
        changeProfileContext()
    }
    
    func changeProfileContext() {
        switch profileContext {
        case .isUser:
            setIsUserState()
        case .following:
            setFollowingState()
        case .notFollowing:
            setNotFollowingState()
        case .pending:
            setPendingState()
        }
    }
    
    func setPendingState() {
        actionPackButtonHandler = {}
        actionPackedButton.setTitle("PENDING", for: UIControlState())
        actionPackedButton.backgroundColor = Colors.basePurple
        actionPackedButton.layer.borderWidth = 0.0
        
    }
    
    func setIsUserState() {
        actionPackButtonHandler = logout
        actionPackedButton.setTitle("LOGOUT", for: UIControlState())
        actionPackedButton.backgroundColor = Colors.basePurple
        actionPackedButton.layer.borderWidth = 0.0
    }
    
    func setFollowingState() {
        actionPackButtonHandler = unfollow
        actionPackedButton.setTitle("UNFOLLOW", for: UIControlState())
        actionPackedButton.backgroundColor = Colors.basePurple
        actionPackedButton.layer.borderWidth = 0.0
    }
    
    func setNotFollowingState() {
        actionPackButtonHandler = follow
        actionPackedButton.setTitle("FOLLOW", for: UIControlState())
        actionPackedButton.backgroundColor = UIColor.clear
        actionPackedButton.layer.borderWidth = 1.0
        actionPackedButton.layer.borderColor = UIColor.white.cgColor
    }
    
    func incrementFollows() {
        _user.numberOfFollowers! += 1
        numberOfFollowersLabel.text = "\(_user.numberOfFollowers!)"
    }
    
    func deincrementFollows() {
        _user.numberOfFollowers! -= 1
        numberOfFollowersLabel.text = "\(_user.numberOfFollowers!)"
    }
    
    func logout() {
        authService.logout()
        delegate.onLoggedOut()
    }
    
    func follow() {
        followService.follow(user: _user, callback: self.setFollowingState)
        incrementFollows()
    }
    
    func unfollow() {
        followService.unfollow(user: _user, callback: self.setNotFollowingState)
        deincrementFollows()
    }
    
    func style() {
        styleCircleImage()
        styleBlurImage()
    }
    
    func styleCircleImage() {
        circleImage.makeCircle()
        circleImage.addShadow()
    }
    
    func styleBlurImage() {
        let blurView = BlurView(onClick: {})
        blurView.frame = CGRect(x:0,y:0,width:frame.width,height:frame.height/2)
        addSubview(blurView)
        bringSubview(toFront: circleImage)
        bringSubview(toFront: fullnameLabel)
        bringSubview(toFront: locationLabel)
        bringSubview(toFront: followerSection)
        bringSubview(toFront: buttonView)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _scenes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:FeedSceneCell = tableView.dequeueReusableCell(withIdentifier: "FeedSceneCell", for: indexPath) as! FeedSceneCell
        let scene = _scenes[(indexPath as NSIndexPath).row]
        let pictureUrl = scene.trip?.owner?.profilePictureURL!
        cell.decorateCell(scene: scene)
        cell.profileImage.imageFromUrl(pictureUrl!, success: { img in
            cell.profileImage.image = img
            cell.profileImage.makeCircle()
        })
        
        cell.tripImage.imageFromUrl(scene.cards[0].imageUrl!)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        let scene: Scene = _scenes[indexPath.row]
        let tripDetailsViewController = TripDetailsViewController(scene: scene)
        let parentViewController = delegate as! UIViewController
        parentViewController.addChildViewController(tripDetailsViewController)
        tripDetailsViewController.view.frame = frame
        addSubview(tripDetailsViewController.view)
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        let lightuponMarker = marker as! LightuponGMSMarker
        self.mapView.selectMarker(lightuponMarker)
        return true
    }
    
    func configureTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        tableView.showsVerticalScrollIndicator = false
        let nibName = UINib(nibName: "FeedSceneCell", bundle:nil)
        tableView.register(nibName, forCellReuseIdentifier: "FeedSceneCell")
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return frame.width + 120
    }
}
