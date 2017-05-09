//
//  ProfileView.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 9/25/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//


// ASGARD

import UIKit
import GoogleMaps

protocol ProfileViewDelegate {
    func onLoggedOut() -> Void
}

protocol ProfileViewCreator {
    func createProfileView(_ userId: Int)
}

enum ProfileContext {
    case isUser, following, notFollowing, pending
}

enum TabBarContext {
    case lights, map
}

class ProfileView: UIView, UITableViewDelegate, UITableViewDataSource, GMSMapViewDelegate {
    fileprivate let authService = Services.shared.getAuthService()
    fileprivate let facebookService = Services.shared.getFacebookService()
    fileprivate let userService = Services.shared.getUserService()
    fileprivate let followService = Services.shared.getFollowService()
    fileprivate let feedService = Services.shared.getFeedService()
    fileprivate let tripService = Services.shared.getTripsService()
    fileprivate let currentLocationService = Services.shared.getCurrentLocationService()

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
    @IBOutlet weak var fadedCoolGuyView: UIView!
    @IBOutlet weak var userNoochView: UIView!
    
    fileprivate var profileContext: ProfileContext = ProfileContext.isUser
    fileprivate var tabBarContext: TabBarContext = TabBarContext.lights
    fileprivate var actionPackButtonHandler:(() -> Void)!
    fileprivate var drawerIsOpen = false
    fileprivate var scrollingUp = false
    fileprivate var drawerHeight: CGFloat = 0.0
    
    fileprivate var _user: User!
    fileprivate var _scenes: [Scene] = [Scene]()
    
    internal var delegate: ProfileViewDelegate!
    
    @IBAction func onActionPackedButtonPress(_ sender: AnyObject) {
        actionPackButtonHandler()
    }
    
    @nonobjc func initializeView(_ userId: Int) {
        getUser(userId)
        configureTableView()
        configureMapView()
        centerMap()
        setTabBar()
        style()
        makeViewsScrollUp()
        makeViewScrollDown()
        makeTabBarDraggable()
    }
    
    func makeTabBarDraggable() {
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(navViewDragged(gestureRecognizer:)))
        tabBar.addGestureRecognizer(gesture)
        tabBar.isUserInteractionEnabled = true
    }
    
    func navViewDragged(gestureRecognizer: UIPanGestureRecognizer){
        let translation = gestureRecognizer.translation(in: self)
        let translationY = drawerIsOpen ? fullnameLabel.frame.origin.y + translation.y: fadedCoolGuyView.frame.height + translation.y
        let newOrigin = CGPoint(x: gestureRecognizer.view!.frame.origin.x, y: translationY)
        
        if gestureRecognizer.state == .ended {
            let height = scrollingUp ? fullnameLabel.frame.origin.y : frame.height / 2
            UIView.animate(withDuration: 0.25, animations: {
                self.userNoochView.frame.origin.y = height
                self.drawerIsOpen = self.scrollingUp
            })
        }
        
        if gestureRecognizer.state == UIGestureRecognizerState.began || gestureRecognizer.state == UIGestureRecognizerState.changed {
            print(newOrigin.y)
            if (newOrigin.y > fullnameLabel.frame.origin.y) && (newOrigin.y < frame.height / 2) {
                scrollingUp = drawerHeight - newOrigin.y > 0
                drawerHeight = newOrigin.y
                userNoochView.frame.origin.y = newOrigin.y
            }
        }
    }
    
    func makeViewsScrollUp() {
        let gesture = UITapGestureRecognizer(target: self, action:  #selector(onDrawerEngaged))
        mapView.addGestureRecognizer(gesture)
        tableView.addGestureRecognizer(gesture)
    }
    
    func makeViewScrollDown() {
        let gesture = UITapGestureRecognizer(target: self, action:  #selector(onCoolGuyViewEngaged))
        fadedCoolGuyView.addGestureRecognizer(gesture)
    }
    
    func onCoolGuyViewEngaged() {
        if drawerIsOpen {
            drawerIsOpen = false
            scrollDown()
        }
    }
    
    func scrollDown() {
        UIView.animate(withDuration: 0.5, animations: {
            self.userNoochView.frame = CGRect(
                x: 0,
                y: self.frame.height / 2,
                width: self.frame.width,
                height: self.frame.height - self.fullnameLabel.frame.origin.y
            )
        })
    }
    
    func onDrawerEngaged() {
        if !drawerIsOpen {
            scrollUp()
            drawerIsOpen = true
        }
    }
    
    func scrollUp() {
        UIView.animate(withDuration: 0.5, animations: {
            self.userNoochView.frame = CGRect(
                x: 0,
                y: self.fullnameLabel.frame.origin.y,
                width: self.frame.width,
                height: self.frame.height - self.fullnameLabel.frame.origin.y
            )
        })
    }
    
    func configureMapView() {
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        mapView.delegate = self
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
        button.setTitleColor(UIColor.basePurple, for: .normal)
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
        feedService.getUsersFeed(userID: _user.id, success: self.onFeedReceived)
    }
    
    func onFeedReceived(scenes: [Scene]) {
        _scenes = scenes
        tableView.reloadData()
    }
    
    func setUser(_ user: User) {
        _user = user
        getUsersFeed()
        setUserContext(user)
        bindUser(user)
    }
    
    func refresh() {
        getUser(_user.id)
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
        actionPackedButton.backgroundColor = UIColor.basePurple
        actionPackedButton.layer.borderWidth = 0.0
        
    }
    
    func setIsUserState() {
        actionPackButtonHandler = logout
        actionPackedButton.setTitle("LOGOUT", for: UIControlState())
        actionPackedButton.backgroundColor = UIColor.basePurple
        actionPackedButton.layer.borderWidth = 0.0
    }
    
    func setFollowingState() {
        actionPackButtonHandler = unfollow
        actionPackedButton.setTitle("UNFOLLOW", for: UIControlState())
        actionPackedButton.backgroundColor = UIColor.basePurple
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
        tabBar.layer.addBorder(edge: .bottom, color: UIColor.mediumGrey, thickness: 1.0)
    }
    
    func styleCircleImage() {
        circleImage.makeCircle()
        circleImage.addShadow()
    }
    
    func styleBlurImage() {
        let blurView = BlurView(onClick: {})
        blurView.frame = fadedCoolGuyView.frame
        fadedCoolGuyView.insertSubview(blurView, aboveSubview: blurImage)
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
        
        cell.tripImage.imageFromUrl(scene.cards[0].imageUrl)
        
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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        onDrawerEngaged()
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        let lightuponMarker = marker as! LightuponGMSMarker
        self.mapView.selectMarker(lightuponMarker)
        return true
    }
    
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        DispatchQueue.main.async {
            self.onDrawerEngaged()
        }
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
