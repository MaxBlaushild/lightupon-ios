//
//  MapViewController.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 1/30/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//

import UIKit
import GoogleMaps
import Alamofire
import MDCSwipeToChoose

class MapViewController: TripModalPresentingViewController,
                         GMSMapViewDelegate,
                         UIImagePickerControllerDelegate,
                         UINavigationControllerDelegate,
                         UICollectionViewDelegate,
                         UICollectionViewDataSource,
                         TripDetailsViewControllerDelegate,
                         PartyServiceDelegate,
                         MDCSwipeToChooseDelegate,
                         LightuponGMSMapViewDelegate,
                         EndOfTripDelegate {
    
    let reuseIdentifier = "MapSceneCell"
    let minimumDistanceTraveled: Double = 1000.00
    let minimumZoomChange: Float = 1.50
    let maximumNumOfMarkers = 800
    let minimumZoom: Float = 8.00
    let maximumRatioTraveled: Double = 3.0
    
    private let currentLocationService = Services.shared.getCurrentLocationService()
    private let tripsService = Services.shared.getTripsService()
    private let feedService = Services.shared.getFeedService()
    private let partyService = Services.shared.getPartyService()
    private let userService = Services.shared.getUserService()
    private let postService = Services.shared.getPostService()
    private let navigationService = Services.shared.getNavigationService()
    
    var trips:[Trip] = [Trip]()
    var scenes: [Scene] = [Scene]()
    
    var xBackButton:XBackButton!
    var compasses:[Compass] = [Compass]()
    
    var delegate: MainViewControllerDelegate!
    var tripDetailsViewController: TripDetailsViewController!
    
    var pastCameraPosition: GMSCameraPosition?
    
    var drawerOpen = false
    var drawerHeight: CGFloat = 0.0
    var scrollingUp = false
    var constellationOverlayVisible = false
    var markerFour: GMSMarker?
    var toggleBackView: UIView!
    var endOfTripView: EndOfTripView!
    var refresher: UIRefreshControl!
    var _nextSceneAvailable = false
    var _cardCount: Int = 0
    var _swipeOptions = CardSwipeOptions()
    var _cardSize: CGRect!
    
    var onViewOpened:((Int) -> Void)!
    var onViewClosed:(() -> Void)!
    
    @IBOutlet weak var checkItOutButton: UIButton!
    @IBOutlet weak var partyButton: UIButton!
    @IBOutlet weak var mapView: LightuponGMSMapView!
    @IBOutlet weak var MapSceneCollectionView: UICollectionView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getScenes()

        MapSceneCollectionView.dataSource = self
        MapSceneCollectionView.delegate = self
        configureMapView()
        initDrawer()
        createCardSize()
        getNearbyScenes(location: nil, radius: nil)
        
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresher.tintColor = .basePurple
        refresher.addTarget(self, action: #selector(refresh), for: .valueChanged)
        
        MapSceneCollectionView.addSubview(refresher)
        MapSceneCollectionView.alwaysBounceHorizontal = true
        
        _swipeOptions.delegate = self
        partyService.registerDelegate(self)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.triggerDeepLinkIfPresent(callback: self.onDeepLink)
        
        NotificationCenter.default.addObserver(self, selector: #selector(onSceneAdded), name: postService.postNotificationName, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onPartyChanged), name: partyService.partyChangeNotificationName, object: nil)
    }
    
    func refresh() {
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getParty()
    }
    
    func onDeepLink(deepLink: DeepLink) {
        if deepLink.resource == "scenes" {
            let sceneId = deepLink.id
            feedService.getScene(sceneId, success: { selectedScene in
                DispatchQueue.main.async {
                    let marker = self.mapView.findOrCreateMarker(scene: selectedScene, blurApplies: false)
                    
                    if let selectedMarker = marker {
                        self.mapView.selectMarker(selectedMarker)
                    }
                    
                    self.mapView.lockState = .unlocked
                    self.toggleDrawer(selectedScene, blurApplies: false)
                    self.onViewOpened(selectedScene.tripId)
                }
            })
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        willDisplaySupplementaryView view: UICollectionReusableView,
                        forElementKind elementKind: String,
                        at indexPath: IndexPath) {
        
        
        
    }
    
    @IBAction func openPartyMenu(_ sender: Any) {
        toggleBackView = UIView(frame: self.view.frame)
        toggleBackView.backgroundColor = .clear
        view.addSubview(toggleBackView)
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(toggleBack))
        toggleBackView.isUserInteractionEnabled = true
        toggleBackView.addGestureRecognizer(tapGestureRecognizer)
        
        delegate.toggleRightPanel()
    }
    
    func toggleBack() {
        toggleBackView.removeFromSuperview()
        toggleBackView = nil
        delegate.toggleRightPanel()
    }
    
    func canStartParty() -> Bool {
        return drawerOpen
    }
    
    @IBAction func checkItOut(_ sender: Any) {
        checkItOutButton.isHidden = true
        loadSwipeViews()
    }
    
    func onSceneAdded(notification: NSNotification) {
        let sceneId = notification.object as! Int
        feedService.getScene(sceneId, success: { scene in
            self.mapView.placeMarker(scene: scene)
        })
    }
    
    func onNextSceneAvailableUpdated(_ nextSceneAvailable: Bool) {
        checkItOutButton.isHidden = !nextSceneAvailable
    }
    
    func getNearbyScenes(location: CLLocationCoordinate2D?, radius: Double?) {
        feedService.getNearbyScenes(
            location: location,
            radius: radius,
            numScenes: 50,
            success: addNearbyScenes
        )
    }
    
    func addNearbyScenes(_ nearbyScenes: [Scene]) {
        mapView.bindScenes(nearbyScenes)
    }
    
    func getParty() {
        partyService.getUsersParty(self.onPartyRetreived)
    }
    
    func createCardSize() {
        _cardSize = CGRect(x: 0, y: 50 + UIApplication.shared.statusBarFrame.height, width: self.view.frame.width, height: self.view.frame.height - (UIApplication.shared.statusBarFrame.height + 50 + (self.tabBarController?.tabBar.frame.size.height)!))
    }
    
    func onPartyRetreived(party: Party?) {
        removeCompasses()
        if let _ = partyService.currentParty {
            MapSceneCollectionView.isHidden = true
            addCompass()
        } else {
            MapSceneCollectionView.isHidden = false
            checkItOutButton.isHidden = true
        }
    }
    
    func onPartyChanged() {
        removeCompasses()
        if let _ = partyService.currentParty {
            MapSceneCollectionView.isHidden = true
            addCompass()
            mapView.lockState = .locked
        } else {
            MapSceneCollectionView.isHidden = false
            checkItOutButton.isHidden = true
            mapView.lockState = .locked
        }
    }
    
    func removeCompasses() {
        compasses.forEach({ compass in
            compass.removeFromSuperview()
        })
        compasses = [Compass]()
    }
    
    func addCompass() {
        if let scene = partyService.currentScene() {
            let compass = Compass.fromNib("Compass")
            let target = scene.cllocation
            compass.pointTowards(target: target)
            compasses.append(compass)
            view.addSubview(compass)
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var shouldAutorotate : Bool {
        return false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
    
    @IBAction func openMenu(_ sender: AnyObject) {
        delegate.toggleRightPanel()
    }

    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return scenes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let scene: Scene = scenes[(indexPath as NSIndexPath).row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! MapSceneCell
        
        cell.MapSceneImage.imageFromUrl(scene.pinUrl!, success: { img in
            cell.MapSceneImage.image = img
            cell.MapSceneImage.makeCircle()
        })
        
        cell.profileImageView.imageFromUrl((scene.trip?.owner?.profilePictureURL)!, success: { img in
            cell.profileImageView.image = img
            cell.profileImageView.makeCircle()
        })
        
 
        
        return cell
    }
    
    func animateInDrawer(duration: TimeInterval, scene: Scene, blurApplies: Bool) {
        tripDetailsViewController.bindScene(scene: scene, blurApplies: blurApplies)
        tripDetailsViewController.setDrawerMode()
        view.bringSubview(toFront: tripDetailsViewController.view)
        UIView.animate(withDuration: duration, animations: {
            self.tripDetailsViewController.view.frame.origin = CGPoint(x: 0, y: self.view.frame.height - (self.tabBarController?.tabBar.frame.size.height)! - 70)
        }, completion: { _ in
            self.drawerOpen = true
        })
    }
    
    func initDrawer() {
        tripDetailsViewController = TripDetailsViewController()
        tripDetailsViewController.view.frame = CGRect(x: 0, y: self.view.frame.height, width: self.view.frame.width, height: self.view.frame.height)
        addChildViewController(tripDetailsViewController)
        makeDrawerDraggable()
        tripDetailsViewController.tripDelegate = self
        view.addSubview(tripDetailsViewController.view)
    }
    
    func makeDrawerDraggable() {
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(navViewDragged(gestureRecognizer:)))
        tripDetailsViewController.view.addGestureRecognizer(gesture)
        tripDetailsViewController.view.isUserInteractionEnabled = true
    }
    
    func onDismissed() {
        tripDetailsViewController = nil
        initDrawer()
        drawerOpen = false
        mapView.clearDirections()
        onViewClosed()
        mapView.unselect()
    }
    
    func onTabChanged() {
        tripDetailsViewController.view.removeFromSuperview()
        tripDetailsViewController.removeFromParentViewController()
        onDismissed()
    }
    
    func mapView(_ mapView: GMSMapView, idleAt cameraPosition: GMSCameraPosition) {
        let currentCameraPosition = mapView.camera
        
        if let pastCameraPosition = self.pastCameraPosition {
            if self.mapView.markers.count > maximumNumOfMarkers {
                self.mapView.clearMarkers()
            }
            
            if shouldSearch(past: pastCameraPosition, current: currentCameraPosition) {
                getNearbyScenes(location: currentCameraPosition.target, radius: self.mapView.getRadius())
            }
        }
        
        pastCameraPosition = currentCameraPosition
    }
    
    func shouldSearch(past: GMSCameraPosition, current: GMSCameraPosition) -> Bool {
        let pastLocation = CLLocation(latitude: past.target.latitude, longitude: past.target.longitude)
        let currentLocation = CLLocation(latitude: current.target.latitude, longitude: current.target.longitude)
        let distanceAway = currentLocation.distance(from: pastLocation)
        let zoomAway = past.zoom - current.zoom
        let radius = self.mapView.getRadius()
        let ratioTraveled = radius / distanceAway
        var shouldSearch = zoomAway > minimumZoomChange || distanceAway > minimumDistanceTraveled
        shouldSearch = shouldSearch || ratioTraveled < maximumRatioTraveled
        shouldSearch = shouldSearch && current.zoom > minimumZoom
        return shouldSearch
    }
    
    func navViewDragged(gestureRecognizer: UIPanGestureRecognizer){
        let translation = gestureRecognizer.translation(in: self.view)
        let newOrigin = CGPoint(x: gestureRecognizer.view!.frame.origin.x, y: gestureRecognizer.view!.frame.origin.y + translation.y)
        
        
        if gestureRecognizer.state == .ended {
            let height = scrollingUp ? UIApplication.shared.statusBarFrame.height : self.view.frame.height - (self.tabBarController?.tabBar.frame.size.height)! - 70
            let beltHeight = scrollingUp ? view.frame.height / 2 : 0
            
            UIView.animate(withDuration: 0.25, animations: {
                self.tripDetailsViewController.view.frame.origin.y = height
                self.tripDetailsViewController.setBeltOverlay(newHeight: beltHeight)
                self.tripDetailsViewController.setBottomViewHeight(newHeight: beltHeight + 70)
            }, completion: { _ in
                if (self.scrollingUp) {
                    self.animateInOverlay()
                }
            })
        }
        
        if gestureRecognizer.state == UIGestureRecognizerState.began || gestureRecognizer.state == UIGestureRecognizerState.changed {
            if (newOrigin.y > UIApplication.shared.statusBarFrame.size.height && newOrigin.y < self.view.frame.height - (self.tabBarController?.tabBar.frame.size.height)! - 70) {
                if (constellationOverlayVisible) {
                    animateOutOverlay()
                }

                gestureRecognizer.view!.frame.origin = newOrigin
                gestureRecognizer.setTranslation(CGPoint(x: 0, y: 0), in: self.view)
                scrollingUp = drawerHeight - newOrigin.y > 0
                drawerHeight = newOrigin.y
                var beltOverlayHeight = (self.view.frame.height - (70 + (self.tabBarController?.tabBar.frame.size.height)!)) - newOrigin.y
                if (beltOverlayHeight <= view.frame.height / 2) {
                    beltOverlayHeight = beltOverlayHeight - beltOverlayHeight * 0.1
                    tripDetailsViewController.setBeltOverlay(newHeight: beltOverlayHeight)
                    tripDetailsViewController.setBottomViewHeight(newHeight: beltOverlayHeight + 70)
                }
            }
        }
    }
    
    func animateOutOverlay() {
        UIView.animate(withDuration: 0.25, animations: {
            self.tripDetailsViewController.setOverlayAlpha(alpha: 0.0)
            self.constellationOverlayVisible = false
        })
    }
    
    func animateInOverlay() {
        UIView.animate(withDuration: 0.25, animations: {
            self.tripDetailsViewController.setOverlayAlpha(alpha: 1.0)
            self.constellationOverlayVisible = true
        })
    }
    
    func animateOutDrawer(duration: TimeInterval) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: duration, animations: {
                self.tripDetailsViewController.view.frame.origin = CGPoint(x: 0, y: self.view.frame.height)
            }, completion: { truth in
                self.drawerOpen = false
            })
        }
    }
    
    func toggleDrawer(_ scene: Scene, blurApplies: Bool) {
        if (drawerOpen) {
            animateOutDrawer(duration: 0.25, completion: { _ in
                self.animateInDrawer(duration: 0.25, scene: scene, blurApplies: blurApplies)
            })
        } else {
            animateInDrawer(duration: 0.5, scene: scene, blurApplies: blurApplies)
        }
    }
    
    func animateOutDrawer(duration: TimeInterval, completion: @escaping (Bool) -> Void) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: duration, animations: {
                self.tripDetailsViewController.view.frame.origin = CGPoint(x: 0, y: self.view.frame.height)
            }, completion: completion)
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedScene = scenes[indexPath.row]
        let marker = mapView.findOrCreateMarker(scene: selectedScene, blurApplies: false)
        
        if let selectedMarker = marker {
            mapView.selectMarker(selectedMarker)
        }

        mapView.lockState = .unlocked
        toggleDrawer(selectedScene, blurApplies: false)
        onViewOpened(selectedScene.tripId)
    }
    
    func getScenes() {
        feedService.getFeed(success: self.addScenes)
    }
    
    func addScenes(_scenes: [Scene]) {
        scenes = _scenes
        MapSceneCollectionView.reloadData()
        bringMapSceneToFront()
    }
    
    func bringMapSceneToFront() {
        view.insertSubview(MapSceneCollectionView, at: 0)
        view.bringSubview(toFront: MapSceneCollectionView)
        
        if tripDetailsViewController != nil {
            view.bringSubview(toFront: tripDetailsViewController.view)
        }
    }

    func configureMapView() {
        mapView.isMyLocationEnabled = true
        mapView.delegate = self
        mapView.lightuponDelegate = self
        mapView.centerMap()
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        self.mapView.unselect()
        onViewClosed()
        self.animateOutDrawer(duration: 0.25)
        self.mapView.setCompassFrame()

    }
    
    func onLocked() {
        self.mapView.unselect()
        onViewClosed()
        self.animateOutDrawer(duration: 0.25)
    }
    

    func mapView(_ mapView: GMSMapView, didChange postion: GMSCameraPosition) {
        compasses.forEach({ compass in
            if let target = compass.target {
                let targetPoint = mapView.projection.point(for: target.coordinate)
                if view.frame.contains(targetPoint) {
                    compass.isHidden = true
                } else {
                    compass.isHidden = false
                }
            }
        })
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        let lightuponMarker = marker as! LightuponGMSMarker
        self.mapView.selectMarker(lightuponMarker)
        self.mapView.lockState = .unlocked
        onViewOpened(lightuponMarker.scene.tripId)
        toggleDrawer(lightuponMarker.scene, blurApplies: true)
        return true
    }
    
    func onSceneChanged(_ scene: Scene) {
        let marker = mapView.findOrCreateMarker(scene: scene, blurApplies: true)
        mapView.selectMarker(marker!)
    }
    
    func openEndOfTripView() {
        endOfTripView = EndOfTripView.fromNib("EndOfTripView")
        endOfTripView.frame = _cardSize
        endOfTripView.delegate = self
        self.view.addSubview(endOfTripView)
    }
    
    
    func handleNoMoreCards() {
        if (partyService.endOfTrip()) {
            openEndOfTripView()
        } else {
            partyService.startNextScene()
        }
    }
    
    func onTripEnds() {
        MapSceneCollectionView.isHidden = false
        checkItOutButton.isHidden = true
        endOfTripView.removeFromSuperview()
        endOfTripView = nil
    }
    
    
    func loadSwipeViews() {
        if let currentScene = partyService.currentScene() {
            for card in currentScene.cards.reversed() {
                _cardCount += 1
                loadCardView(card, scene: currentScene)
            }
        }
    }

    func loadCardView(_ card: Card, scene: Scene) {
        let owner = userService.currentUser
        let cardView = CardView(card: card, scene: scene, owner: owner, options:_swipeOptions, frame: _cardSize)
        
        cardView.layer.borderWidth = 0.0
        view.addSubview(cardView)
    }
    
    func viewDidCancelSwipe(_ view: UIView) -> Void {}
    
    func view(_ view:UIView, shouldBeChosenWith shouldBeChosenWithDirection:MDCSwipeDirection) -> Bool {
        return true
    }
    
    func view(_ view: UIView, wasChosenWith wasChosenWithDirection: MDCSwipeDirection) -> Void{
        _cardCount -= 1
        
        if (_cardCount == 0) {
            handleNoMoreCards()
        }
    }
    

}
