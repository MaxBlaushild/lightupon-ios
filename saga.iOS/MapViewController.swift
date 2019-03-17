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
import Observable

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
                         CameraOverlayDelegate,
                         CardViewControllerDelegate,
                         ProfileViewDelegate,
                         MDCSwipeToChooseDelegate,
                         LightuponGMSMapViewDelegate {
    
    let minimumDistanceTraveled: Double = 1000.00
    let minimumZoomChange: Float = 1.50
    let maximumNumOfMarkers = 800
    let minimumZoom: Float = 8.00
    let maximumRatioTraveled: Double = 3.0
    let imagePicker = UIImagePickerController()
    
    private let currentLocationService = Services.shared.getCurrentLocationService()
    private let questService = Services.shared.getQuestService()
    private let feedService = Services.shared.getFeedService()
    private let userService = Services.shared.getUserService()
    private let postService = Services.shared.getPostService()

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
    var nextSceneAvailable = false
    var cardSize: CGRect!
    var updateTime: Timer!
    var _users: [User] = [User]()
    var posts: [Post] = [Post]()
    var focusedQuestDisposable: Disposable!
    var isFocusing = false

    fileprivate var profileView: ProfileView!
    @IBOutlet weak var partyButton: UIButton!
    @IBOutlet weak var mapView: LightuponGMSMapView!
    @IBOutlet weak var sideMenuButton: UIButton!
    @IBOutlet weak var focusedCompass: Compass!
    
    var barButtonItems: [CircularButton]!

    @IBOutlet weak var lockButton: CircularButton!
    @IBOutlet weak var postButton: CircularButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        configureMapView()
        initDrawer()
        styleSidebarButton()
        setLockButton()
        getNearbyPosts(location: currentLocationService.location.cllocation.coordinate, radius: self.mapView.getRadius())
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.triggerDeepLinkIfPresent(callback: self.onDeepLink)
        
        NotificationCenter.default.addObserver(self, selector: #selector(onSceneAdded), name: postService.postNotificationName, object: nil)
        
        focusedQuestDisposable = questService.observeFocusChanges({ focusedQuest in
            if let quest = focusedQuest.quest {
                self.isFocusing = true
                self.mapView.lockState = .locked
                self.setLockButton()
                
                if let nextPost = quest.nextPost {
                    self.focusedCompass.isHidden = false
                    self.focusedCompass.pointTowards(target: nextPost.cllocation)
                    self.focusedCompass.twirl()
                }
            } else {
                self.focusedCompass.isHidden = true
                self.isFocusing = false
            }
        })
        
        view.bringSubview(toFront: focusedCompass)
    }
    
    @IBAction func toggleLock(_ sender: Any) {
        mapView.lockState = mapView.lockState == .locked ? .unlocked : .locked
        setLockButton()
    }
    
    func setLockButton() {
        if mapView.lockState == .locked {
            lockButton.setImage(UIImage(named: "locked"), for: .normal)
            
            if isFocusing {
                focusedCompass.isHidden = false
                focusedCompass.twirl()
            }

        } else {
            lockButton.setImage(UIImage(named: "unlocked"), for: .normal)
            focusedCompass.isHidden = true
        }
        lockButton.setImageTint(color: .basePurple)
    }
    
    @IBAction func post(_ sender: Any) {
        openCamera()
    }
    
    func createProfileView(userID: Int) {
        profileView = ProfileView.fromNib("ProfileView")
        profileView.frame = view.frame
        profileView.delegate = self
        profileView.initializeView(userID)
        view.addSubview(profileView)
        addXBackButton()
    }

    
    func resetBarItems() {
        barButtonItems.forEach({ item in
            item.layer.borderWidth = 0.0
        })
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
    
    func styleSidebarButton() {
        Alamofire.request(userService.currentUser.profilePictureURL, method: .get, parameters: nil).responseJSON { response in
            if let imageData = response.data {
                let image = UIImage(data: imageData)
                let selectedImage = Toucan(image: image!).resize(CGSize(width: 50, height: 50), fitMode: Toucan.Resize.FitMode.scale).maskWithEllipse(borderWidth: 3, borderColor: UIColor.white).resize(CGSize(width: 50, height: 50), fitMode: Toucan.Resize.FitMode.scale).maskWithEllipse(borderWidth: 2, borderColor: UIColor.basePurple).image?.withRenderingMode(.alwaysOriginal)
                self.sideMenuButton.setImage(selectedImage, for: .normal)
                self.view.bringSubview(toFront: self.sideMenuButton)
            }

        }
    }
    
    func onDeepLink(deepLink: DeepLink) {
        if deepLink.resource == "scenes" {
            let postId = deepLink.id
            feedService.getPost(postId, success: { post in
                DispatchQueue.main.async {
                    let marker = self.mapView.findOrCreateMarker(post: post, blurApplies: false)
                    
                    if let selectedMarker = marker {
                        self.mapView.selectMarker(selectedMarker)
                    }
                    
                    self.mapView.lockState = .unlocked
                    self.setLockButton()
                    self.toggleDrawer(post, blurApplies: true)
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

    func onSceneAdded(notification: NSNotification) {
        let sceneId = notification.object as! Int
        feedService.getPost(sceneId, success: { post in
            self.mapView.placeMarker(post: post)
        })
    }
    
    func getNearbyPosts(location: CLLocationCoordinate2D?, radius: Double?) {
        feedService.getNearbyPosts(
            location: location,
            radius: radius,
            numScenes: 50,
            success: addNearbyPosts
        )
    }
    
    func addNearbyPosts(_ nearbyPosts: [Post]) {
        mapView.bindPosts(nearbyPosts)
    }
    
    func removeCompasses() {
        compasses.forEach({ compass in
            compass.removeFromSuperview()
        })
        compasses = [Compass]()
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

    
    func onLoggedOut() {}
    
    func addXBackButton() {
        let frame = CGRect(x: view.bounds.width - 45, y: 30, width: 30, height: 30)
        xBackButton = XBackButton(frame: frame)
        xBackButton.addTarget(self, action: #selector(dismissProfile), for: .touchUpInside)
        view.addSubview(xBackButton)
    }
    
    func dismissProfile() {
        profileView.removeFromSuperview()
        xBackButton.removeFromSuperview()
    }
    
    func animateInDrawer(duration: TimeInterval, post: Post, blurApplies: Bool) {
        cardViewController.bindContext(post: post, blurApplies: true)
        view.bringSubview(toFront: cardViewController.view)
        cardViewController.setStartingBottomViewHeight()
        self.cardViewController.setOverlayAlpha(alpha: 0.0)
        UIView.animate(withDuration: duration, animations: {
            self.cardViewController.view.frame.origin = CGPoint(x: 0, y: self.view.frame.height - 70)
        }, completion: { _ in
            self.drawerOpen = true
        })
    }
    
    func initDrawer() {
        cardViewController = UIStoryboard.cardViewController()
        cardViewController.view.frame = CGRect(x: 0, y: self.view.frame.height, width: self.view.frame.width, height: self.view.frame.height)
        cardViewController.delegate = self
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
        cardViewController.view.removeFromSuperview()
        cardViewController.removeFromParentViewController()
        cardViewController = nil
        initDrawer()
        drawerOpen = false
        mapView.unselect()
    }
    
    func mapView(_ mapView: GMSMapView, idleAt cameraPosition: GMSCameraPosition) {
        let currentCameraPosition = mapView.camera
        
        if let pastCameraPosition = self.pastCameraPosition {
            if self.mapView.markers.count > maximumNumOfMarkers {
                self.mapView.clearMarkers()
            }
            
            if shouldSearch(past: pastCameraPosition, current: currentCameraPosition) {
                getNearbyPosts(location: currentCameraPosition.target, radius: self.mapView.getRadius())
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
                let currentHeight = (self.view.frame.height - (70)) - newOrigin.y
                let offsetPercentage = currentHeight / (self.view.frame.height - 70)
                let bottomOffset = offsetPercentage * cardViewController.sceneImageView.frame.height
                let thing = cardViewController.sceneImageView.frame.height - bottomOffset
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
//                
            }, completion: { truth in
                self.drawerOpen = false
            })
        }
    }
    
    func toggleDrawer(_ post: Post, blurApplies: Bool) {
        if (drawerOpen) {
            animateOutDrawer(duration: 0.25, completion: { _ in
                self.animateInDrawer(duration: 0.25, post: post, blurApplies: blurApplies)
            })
        } else {
            animateInDrawer(duration: 0.5, post: post, blurApplies: blurApplies)
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

    func configureMapView() {
        mapView.isMyLocationEnabled = true
        mapView.delegate = self
        mapView.lightuponDelegate = self
        mapView.centerMap()
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        self.mapView.unselect()
        self.animateOutDrawer(duration: 0.25)
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
        setLockButton()
        toggleDrawer(lightuponMarker.post, blurApplies: true)
        return true
    }
    
}
