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
    
    private let currentLocationService = Services.shared.getCurrentLocationService()
    private let tripsService = Services.shared.getTripsService()
    private let feedService = Services.shared.getFeedService()
    private let partyService = Services.shared.getPartyService()
    private let userService = Services.shared.getUserService()
    private let postService = Services.shared.getPostService()
    
    var trips:[Trip] = [Trip]()
    var scenes: [Scene] = [Scene]()
    
    var xBackButton:XBackButton!
    var compasses:[Compass] = [Compass]()
    
    var delegate: MainViewControllerDelegate!
    var mapDrawer: TripDetailsViewController!
    
    var drawerOpen = false
    var drawerHeight: CGFloat = 0.0
    var scrollingUp = false
    var constellationOverlayVisible = false
    var markerFour: GMSMarker?
    var endOfTripView: EndOfTripView!
    var _nextSceneAvailable = false
    var _cardCount: Int = 0
    var _swipeOptions = CardSwipeOptions()
    var _cardSize: CGRect!
    
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
        getNearbyScenes()

        
        _swipeOptions.delegate = self
        partyService.registerDelegate(self)
        
        NotificationCenter.default.addObserver(self, selector: #selector(onSceneAdded), name: postService.postNotificationName, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onPartyChanged), name: partyService.partyChangeNotificationName, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getParty()
    }
    
    @IBAction func openPartyMenu(_ sender: Any) {
        delegate.toggleRightPanel()
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
    
    func getNearbyScenes() {
        feedService.getNearbyScenes(success: addNearbyScenes)
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
        let scene = partyService.currentScene()
        let compass = Compass.fromNib("Compass")
        let target = scene?.cllocation
        compass.pointTowards(target: target!)
        compasses.append(compass)
        view.addSubview(compass)
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
    
    func animateInDrawer(duration: TimeInterval, scene: Scene) {
        mapDrawer.bindScene(scene: scene)
        mapDrawer.setDrawerMode()
        view.bringSubview(toFront: mapDrawer.view)
        UIView.animate(withDuration: duration, animations: {
            self.mapDrawer.view.frame.origin = CGPoint(x: 0, y: self.view.frame.height - (self.tabBarController?.tabBar.frame.size.height)! - 70)
        }, completion: { _ in
            self.drawerOpen = true
        })
    }
    
    func initDrawer() {
        mapDrawer = TripDetailsViewController()
        mapDrawer.view.frame = CGRect(x: 0, y: self.view.frame.height, width: self.view.frame.width, height: self.view.frame.height)
        addChildViewController(mapDrawer)
        makeDrawerDraggable()
        mapDrawer.tripDelegate = self
        view.addSubview(mapDrawer.view)
    }
    
    func makeDrawerDraggable() {
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(navViewDragged(gestureRecognizer:)))
        mapDrawer.view.addGestureRecognizer(gesture)
        mapDrawer.view.isUserInteractionEnabled = true
    }
    
    func onDismissed() {
        mapDrawer = nil
        initDrawer()
        drawerOpen = false
        mapView.clearDirections()
    }
    func mapView(_ mapView: GMSMapView, idleAt cameraPosition: GMSCameraPosition) {
//        if self.mapView.lockState == .unlocked {
//            DispatchQueue.main.async {

//            }
//        }

    }
    
    func navViewDragged(gestureRecognizer: UIPanGestureRecognizer){
        let translation = gestureRecognizer.translation(in: self.view)
        let newOrigin = CGPoint(x: gestureRecognizer.view!.frame.origin.x, y: gestureRecognizer.view!.frame.origin.y + translation.y)
        
        
        if gestureRecognizer.state == .ended {
            let height = scrollingUp ? UIApplication.shared.statusBarFrame.height : self.view.frame.height - (self.tabBarController?.tabBar.frame.size.height)! - 70
            let beltHeight = scrollingUp ? view.frame.height / 2 : 0
            
            UIView.animate(withDuration: 0.25, animations: {
                self.mapDrawer.view.frame.origin.y = height
                self.mapDrawer.setBeltOverlay(newHeight: beltHeight)
                self.mapDrawer.setBottomViewHeight(newHeight: beltHeight + 70)
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
                    mapDrawer.setBeltOverlay(newHeight: beltOverlayHeight)
                    mapDrawer.setBottomViewHeight(newHeight: beltOverlayHeight + 70)
                }
            }
        }
    }
    
    func animateOutOverlay() {
        UIView.animate(withDuration: 0.25, animations: {
            self.mapDrawer.setOverlayAlpha(alpha: 0.0)
            self.constellationOverlayVisible = false
        })
    }
    
    func animateInOverlay() {
        UIView.animate(withDuration: 0.25, animations: {
            self.mapDrawer.setOverlayAlpha(alpha: 1.0)
            self.constellationOverlayVisible = true
        })
    }
    
    func animateOutDrawer(duration: TimeInterval) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: duration, animations: {
                self.mapDrawer.view.frame.origin = CGPoint(x: 0, y: self.view.frame.height)
            }, completion: { truth in
                self.drawerOpen = false
            })
        }
    }
    
    func toggleDrawer(_ scene: Scene) {
        if (drawerOpen) {
            animateOutDrawer(duration: 0.25, completion: { _ in
                self.animateInDrawer(duration: 0.25, scene: scene)
            })
        } else {
            animateInDrawer(duration: 0.5, scene: scene)
        }
    }
    
    func animateOutDrawer(duration: TimeInterval, completion: @escaping (Bool) -> Void) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: duration, animations: {
                self.mapDrawer.view.frame.origin = CGPoint(x: 0, y: self.view.frame.height)
            }, completion: completion)
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedScene = scenes[indexPath.row]
        let marker = mapView.findOrCreateMarker(scene: selectedScene)
        
        if let selectedMarker = marker {
            mapView.selectMarker(selectedMarker)
        }

        mapView.lockState = .unlocked
        toggleDrawer(selectedScene)
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
        
        if mapDrawer != nil {
            view.bringSubview(toFront: mapDrawer.view)
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
        self.animateOutDrawer(duration: 0.25)
        self.mapView.setCompassFrame()

    }
    
    func onLocked() {
        self.mapView.unselect()
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
        toggleDrawer(lightuponMarker.scene)
        return true
    }
    
    func onSceneChanged(_ scene: Scene) {
        let marker = mapView.findOrCreateMarker(scene: scene)
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
