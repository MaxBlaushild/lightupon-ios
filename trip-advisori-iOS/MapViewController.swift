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

class MapViewController: TripModalPresentingViewController,
                         GMSMapViewDelegate,
                         UIImagePickerControllerDelegate,
                         UINavigationControllerDelegate,
                         UICollectionViewDelegate,
                         UICollectionViewDataSource,
                         TripDetailsViewControllerDelegate,
                         CurrentLocationServiceDelegate,
                         LightuponGMSMapViewDelegate {
    
    let reuseIdentifier = "MapSceneCell"
    
    private let currentLocationService = Services.shared.getCurrentLocationService()
    private let tripsService = Services.shared.getTripsService()
    private let feedService = Services.shared.getFeedService()
    private let partyService = Services.shared.getPartyService()
    
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
    
    @IBOutlet weak var litButton: LitButton!
    @IBOutlet weak var mapView: LightuponGMSMapView!
    @IBOutlet weak var MapSceneCollectionView: UICollectionView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        MapSceneCollectionView.dataSource = self
        MapSceneCollectionView.delegate = self
        litButton.delegate = self
        configureMapView()
        initDrawer()
        
        let visibleRegion = mapView.projection.visibleRegion()
        let nearleftPosition = visibleRegion.nearLeft
        let markerOne = GMSMarker(position: nearleftPosition)
        markerOne.title = "Hello World"
        markerOne.map = mapView
        let nearRightPosition = visibleRegion.nearRight
        let markerTwo = GMSMarker(position: nearRightPosition)
        markerTwo.title = "Hello World"
        markerTwo.map = mapView
        let farLeftPosition = visibleRegion.farLeft
        let markerThree = GMSMarker(position: farLeftPosition)
        markerThree.title = "Hello World"
        markerThree.map = mapView
        let farRightPosition = visibleRegion.farRight
        markerFour = GMSMarker(position: farRightPosition)
        markerFour?.title = "Hello World"
        markerFour!.map = mapView
        
        currentLocationService.registerDelegate(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getTrips()
        getScenes()
        getParty()
    }
    
    func getParty() {
        partyService.getUsersParty(self.onPartyRetreived)
    }
    
    func onPartyRetreived(party: Party?) {
        if let _ = partyService.currentParty {
            MapSceneCollectionView.isHidden = true
            addCompass()
//            view.bringSubview(toFront: mapView)
        }
    }
    
    func onLocationUpdated() {
    
    }
    
    func onHeadingUpdated() {
        if let marker = markerFour {
            print(mapView.projection.point(for: marker.position))
            print(mapView.projection.contains(marker.position))
        }

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
        
        cell.MapSceneImage.imageFromUrl(scene.backgroundUrl!, success: { img in
            scene.image = img
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
        let marker = mapView.findOrCreateMarker(byScene: selectedScene)
        
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
    
    func getTrips() {
        tripsService
            .getTrips(self.onTripsGotten,
                              latitude: self.currentLocationService.latitude,
                              longitude: self.currentLocationService.longitude
        )
    }
    
    func onTripsGotten(_ _trips_: [Trip]) {
        trips = _trips_
        mapView.bindTrips(trips)
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
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        let lightuponMarker = marker as! LightuponGMSMarker
        self.mapView.selectMarker(lightuponMarker)
        self.mapView.lockState = .unlocked
        toggleDrawer(lightuponMarker.scene)
        return true
    }
    
    func onSceneChanged(_ scene: Scene) {
        let marker = mapView.findOrCreateMarker(byScene: scene)
        mapView.selectMarker(marker!)
    }
    
    func segueToContainer() {
        performSegue(withIdentifier: "MapToContainer", sender: self)
    }

}
