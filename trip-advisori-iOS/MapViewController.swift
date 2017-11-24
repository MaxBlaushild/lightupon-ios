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
import Toucan

private extension UIStoryboard {
    class func mainStoryboard() -> UIStoryboard { return UIStoryboard(name: "Main", bundle: Bundle.main) }
    
    class func cardViewController() -> CardViewController? {
        return mainStoryboard().instantiateViewController(withIdentifier: "CardViewController") as? CardViewController
    }
}

class MapViewController: UIViewController,
                         GMSMapViewDelegate,
                         UIImagePickerControllerDelegate,
                         UINavigationControllerDelegate,
                         UICollectionViewDelegate,
                         CameraOverlayDelegate,
                         UICollectionViewDataSource,
                         PartyServiceDelegate,
                         MDCSwipeToChooseDelegate,
                         LightuponGMSMapViewDelegate,
                         UIScrollViewDelegate,
                         EndOfTripDelegate {
    
    let reuseIdentifier = "MapSceneCell"
    let minimumDistanceTraveled: Double = 1000.00
    let minimumZoomChange: Float = 1.50
    let maximumNumOfMarkers = 800
    let minimumZoom: Float = 8.00
    let maximumRatioTraveled: Double = 3.0
    let imagePicker = UIImagePickerController()
    
    private let currentLocationService = Services.shared.getCurrentLocationService()
    private let tripsService = Services.shared.getTripsService()
    private let feedService = Services.shared.getFeedService()
    private let partyService = Services.shared.getPartyService()
    private let userService = Services.shared.getUserService()
    private let postService = Services.shared.getPostService()
    private let navigationService = Services.shared.getNavigationService()
    private let discoveryService = Services.shared.getDiscoveryService()
    
    var trips:[Trip] = [Trip]()
    var scenes: [Scene] = [Scene]()
    
    var xBackButton:XBackButton!
    var compasses:[Compass] = [Compass]()
    
    var delegate: MainViewControllerDelegate!
    var cardViewController: CardViewController!
    var mainButton: UIButton!
    
    var pastCameraPosition: GMSCameraPosition?
    
    var drawerOpen = false
    var drawerHeight: CGFloat = 0.0
    var scrollingUp = false
    var constellationOverlayVisible = false
    var markerFour: GMSMarker?
    var toggleBackView: UIView!
    var endOfTripView: EndOfTripView!
    var nextSceneAvailable = false
    var cardCount: Int = 0
    var swipeOptions = CardSwipeOptions()
    var cardSize: CGRect!
    var updateTime: Timer!
    var page = 0
    
    var onViewOpened:((Int) -> Void)!
    var onViewClosed:(() -> Void)!
    
    @IBOutlet weak var checkItOutButton: UIButton!
    @IBOutlet weak var partyButton: UIButton!
    @IBOutlet weak var mapView: LightuponGMSMapView!
    @IBOutlet weak var MapSceneCollectionView: UICollectionView!
    @IBOutlet weak var sideMenuButton: UIButton!
    @IBOutlet weak var mapBottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getScenes(callback: nil)

        MapSceneCollectionView.dataSource = self
        MapSceneCollectionView.delegate = self
        configureMapView()
        initDrawer()
        createCardSize()
        styleSidebarButton()
        getNearbyScenes(location: nil, radius: nil)
        addMainButton()
        
        MapSceneCollectionView.alwaysBounceHorizontal = true
        
        swipeOptions.delegate = self
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.triggerDeepLinkIfPresent(callback: self.onDeepLink)
        
        self.updateTime = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(discover), userInfo: nil, repeats: true)
        
        NotificationCenter.default.addObserver(self, selector: #selector(onSceneAdded), name: postService.postNotificationName, object: nil)
    }
    
    func openCamera() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            let overlay = CameraOverlay.fromNib("CameraOverlay")
            overlay.initialize(self, picker: imagePicker)
            self.present(imagePicker, animated: true, completion: nil)
            self.view.bringSubview(toFront: overlay)
        }
    }
    
    func onCancelPressed() {
        dismiss(animated: true, completion: nil)
    }
    
    func onPhotoConfirmed() {
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
            self.performSegue(withIdentifier: "MapToSceneForm", sender: nil)
        }
    }
    
    func addMainButton() {
        mainButton = UIButton(type: .custom)
        mainButton.frame = CGRect(x: view.frame.width / 2 - 30, y: view.frame.height - 110, width: 60, height: 60)
        mainButton.center = CGPoint(x:view.center.x , y: mainButton.center.y)
        mainButton.backgroundColor = UIColor.white
        mainButton.addTarget(self, action: #selector(openCamera), for: .touchUpInside)
        mainButton.layer.borderColor = UIColor.basePurple.cgColor
        mainButton.layer.borderWidth = 3.0
        mainButton.makeCircle()
        view.addSubview(mainButton)
    }
    
    func styleSidebarButton() {
        Alamofire.request(userService.currentUser.profilePictureURL, method: .get, parameters: nil).responseJSON { response in
            if let imageData = response.data {
                let image = UIImage(data: imageData)
                let selectedImage = Toucan(image: image!).resize((self.sideMenuButton.imageView?.frame.size)!, fitMode: Toucan.Resize.FitMode.scale).maskWithEllipse(borderWidth: 3, borderColor: UIColor.white).resize((self.sideMenuButton.imageView?.frame.size)!, fitMode: Toucan.Resize.FitMode.scale).maskWithEllipse(borderWidth: 2, borderColor: UIColor.basePurple).image.withRenderingMode(.alwaysOriginal)
                self.sideMenuButton.setImage(selectedImage, for: .normal)
            }

        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset
        let inset = scrollView.contentInset
        let y: CGFloat = offset.x - inset.left
        let reload_distance: CGFloat = -75
        if y < reload_distance {
            page = 0
            getScenes(callback: nil)
        }
    }
    
    func discover() {
        mapView.markers.forEach(discoveryService.discover)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getParty()
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        let lastRowIndex = MapSceneCollectionView.numberOfItems(inSection: 0)
        if indexPath.row == lastRowIndex - 1 {
            getScenes(callback: { _scenes in
                self.scenes.append(contentsOf: _scenes)
                self.MapSceneCollectionView.reloadData()
            })
        }
        
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
        cardSize = CGRect(x: 0, y: 50 + UIApplication.shared.statusBarFrame.height, width: self.view.frame.width, height: self.view.frame.height - (UIApplication.shared.statusBarFrame.height + 50))
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
        cardViewController.bindContext(card: scene.cards[0], owner: scene.trip!.owner!, scene: scene, blurApplies: true)
        view.bringSubview(toFront: cardViewController.view)
        cardViewController.setStartingBottomViewHeight()
        self.cardViewController.setOverlayAlpha(alpha: 0.0)
        UIView.animate(withDuration: duration, animations: {
            self.cardViewController.view.frame.origin = CGPoint(x: 0, y: self.view.frame.height - 70)
//            self.mapBottomConstraint.constant = 0
        }, completion: { _ in
            self.drawerOpen = true
        })
    }
    
    func initDrawer() {
        cardViewController = UIStoryboard.cardViewController()
        cardViewController.view.frame = CGRect(x: 0, y: self.view.frame.height, width: self.view.frame.width, height: self.view.frame.height)
        addChildViewController(cardViewController)
        makeDrawerDraggable()
        view.addSubview(cardViewController.view)
    }
    
    func makeDrawerDraggable() {
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(navViewDragged(gestureRecognizer:)))
        cardViewController.view.addGestureRecognizer(gesture)
        cardViewController.view.isUserInteractionEnabled = true
    }
    
    func onDismissed() {
        cardViewController = nil
        initDrawer()
        drawerOpen = false
        mapView.clearDirections()
        mapView.unselect()
    }
    
    func onTabChanged() {
        cardViewController.view.removeFromSuperview()
        cardViewController.removeFromParentViewController()
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
            let height = scrollingUp ? UIApplication.shared.statusBarFrame.height : self.view.frame.height  - 70
            let bottomViewHeight = scrollingUp ? 0 : cardViewController.sceneImageView.frame.height * -1.0
            let overlayAlpha: CGFloat = scrollingUp ? 0.6 : 0.0
            self.cardViewController.view.layoutIfNeeded()
            UIView.animate(withDuration: 0.25, animations: {
                self.cardViewController.bottomViewTopConstraint.constant = bottomViewHeight
                self.cardViewController.view.setNeedsLayout()
                self.cardViewController.view.layoutIfNeeded()
                self.cardViewController.view.frame.origin.y = height
                
            }, completion: { _ in
//                if (self.scrollingUp) {
//                    self.animateInOverlay()
//                }
                self.cardViewController.setOverlayAlpha(alpha: overlayAlpha)
            })
        }
        
        if gestureRecognizer.state == UIGestureRecognizerState.began || gestureRecognizer.state == UIGestureRecognizerState.changed {
            if (newOrigin.y > UIApplication.shared.statusBarFrame.size.height && newOrigin.y < self.view.frame.height) {
                gestureRecognizer.view!.frame.origin = newOrigin
                gestureRecognizer.setTranslation(CGPoint(x: 0, y: 0), in: self.view)
                scrollingUp = drawerHeight - newOrigin.y > 0
                drawerHeight = newOrigin.y
                var currentHeight = (self.view.frame.height - (70)) - newOrigin.y
                var offsetPercentage = currentHeight / (self.view.frame.height - 70)
                var bottomOffset = offsetPercentage * cardViewController.sceneImageView.frame.height
                var thing = cardViewController.sceneImageView.frame.height - bottomOffset
                cardViewController.setBottomViewHeight(newHeight: thing * -1.0)
                
                if (!scrollingUp && self.cardViewController.overlay.alpha == 0.6) {
                    UIView.animate(withDuration: 0.25, animations: {
                        self.cardViewController.setOverlayAlpha(alpha: 0.0)
                    })
                }
            }
        }
    }
    
    func animateOutOverlay() {
        UIView.animate(withDuration: 0.25, animations: {
//            self.cardViewController.setOverlayAlpha(alpha: 0.0)
//            self.constellationOverlayVisible = false
        })
    }
    
    func animateInOverlay() {
        UIView.animate(withDuration: 0.25, animations: {
            self.cardViewController.setOverlayAlpha(alpha: 0.6)
            self.cardViewController.overlay.isHidden = false
        })
    }
    
    func animateOutDrawer(duration: TimeInterval) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: duration, animations: {
                self.cardViewController.view.frame.origin = CGPoint(x: 0, y: self.view.frame.height)
//                self.mapBottomConstraint.constant = self.view.frame.height * 0.4
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
                self.cardViewController.view.frame.origin = CGPoint(x: 0, y: self.view.frame.height)
//                self.mapBottomConstraint.constant = self.view.frame.height * 0.4
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
    }
    
    func getScenes(callback: (([Scene]) -> Void)?) {
        let success = callback ?? addScenes
        feedService.getFeed(page: page, success: success)
        page += 1
    }
    
    func addScenes(_scenes: [Scene]) {
        scenes = _scenes
        MapSceneCollectionView.reloadData()
        bringMapSceneToFront()
    }
    
    func bringMapSceneToFront() {
        view.insertSubview(MapSceneCollectionView, at: 0)
        view.bringSubview(toFront: MapSceneCollectionView)
        
        if cardViewController != nil {
            view.bringSubview(toFront: cardViewController.view)
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
//        onViewOpened(lightuponMarker.scene.tripId)
        toggleDrawer(lightuponMarker.scene, blurApplies: true)
        return true
    }
    
    func onSceneChanged(_ scene: Scene) {
        let marker = mapView.findOrCreateMarker(scene: scene, blurApplies: true)
        mapView.selectMarker(marker!)
    }
    
    func openEndOfTripView() {
        endOfTripView = EndOfTripView.fromNib("EndOfTripView")
        endOfTripView.frame = cardSize
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
                cardCount += 1
                loadCardView(card, scene: currentScene)
            }
        }
    }

    func loadCardView(_ card: Card, scene: Scene) {
        let owner = userService.currentUser
        let cardView = CardView(card: card, scene: scene, owner: owner, options:swipeOptions, frame: cardSize)
        
        cardView.layer.borderWidth = 0.0
        view.addSubview(cardView)
    }
    
    func viewDidCancelSwipe(_ view: UIView) -> Void {}
    
    func view(_ view:UIView, shouldBeChosenWith shouldBeChosenWithDirection:MDCSwipeDirection) -> Bool {
        return true
    }
    
    func view(_ view: UIView, wasChosenWith wasChosenWithDirection: MDCSwipeDirection) -> Void{
        cardCount -= 1
        
        if (cardCount == 0) {
            handleNoMoreCards()
        }
    }
    

}
