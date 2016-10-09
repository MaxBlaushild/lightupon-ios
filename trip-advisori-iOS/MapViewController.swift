//
//  MapViewController.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 1/30/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//

import UIKit
import GoogleMaps

class MapViewController: UIViewController, GMSMapViewDelegate, TripDetailsViewDelegate {
    
    fileprivate let currentLocationService:CurrentLocationService = Injector.sharedInjector.getCurrentLocationService()
    fileprivate let tripsService:TripsService = Injector.sharedInjector.getTripsService()
    fileprivate let litService:LitService = Injector.sharedInjector.getLitService()
    fileprivate let userService:UserService = Injector.sharedInjector.getUserService()
    
    var trips:[Trip]!
    
    var blurView: BlurView!
    var tripDetailsView:TripDetailsView!
    var xBackButton:XBackButton!
    
    var delegate: MainViewControllerDelegate!
    
    
    @IBAction func openMenu(_ sender: AnyObject) {
        delegate.toggleRightPanel()
    }
    
    @IBAction func toggleLitness(_ sender: AnyObject) {
        litService.isLit ? extinguish() : light()
    }
    
    func light() {
        litService.light(successCallback: self.bindLitness)
    }
    
    func extinguish() {
        litService.extinguish(successCallback: self.bindLitness)
    }
    
    func bindLitness() {
        let title = litService.isLit ? "Get Unlit" : "Get Lit"
        litButton.setTitle(title, for: .normal)
    }
    
    
    @IBOutlet weak var litButton: UIButton!
    
    @IBOutlet weak var mapView: GMSMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getTrips()
        configureMapView()
        bindLitness()
        view.bringSubview(toFront: litButton)
    }
    
    func configureMapView() {
        mapView.camera = GMSCameraPosition.camera(withLatitude: currentLocationService.latitude, longitude: currentLocationService.longitude, zoom: 15)
        mapView.isMyLocationEnabled = true
        mapView.delegate = self
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var shouldAutorotate : Bool {
        return false
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
    
    func getTrips() {
        tripsService.getTrips(self.onTripsGotten, latitude: self.currentLocationService.latitude, longitude: self.currentLocationService.longitude)
    }
    
    func onTripsGotten(_ _trips_: [Trip]) {
        trips = _trips_
        initMap()
    }
    
    func initMap() {
        for trip in trips {
            placeTripOnMap(trip, mapView: mapView)
        }
    }

    func getRandomColor() -> UIColor{
        let randomRed:CGFloat = CGFloat(drand48())
        let randomGreen:CGFloat = CGFloat(drand48())
        let randomBlue:CGFloat = CGFloat(drand48())
        return UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 1.0)
    }
    
    func placeTripOnMap(_ trip: Trip, mapView: GMSMapView) {
        let colorForTrip = getRandomColor()
        placeLocations(trip: trip, color: colorForTrip)
        placeMarkers(trip: trip, color: colorForTrip)

    }
    
    func placeLocations(trip: Trip, color: UIColor) {
        if trip.locations != nil {
            let path = GMSMutablePath()
            
            for location in trip.locations! {
                let coord = CLLocationCoordinate2D(latitude: location.latitude!, longitude: location.longitude!)
                path.add(coord)
            }
            
            let polyline = GMSPolyline(path: path)
            polyline.strokeColor = color
            polyline.map = mapView
        }

    }
    
    func placeMarkers(trip: Trip, color: UIColor) {
        if trip.scenes != nil {
            for scene in trip.scenes! {
                placeMarker(scene: scene, color: color)
            }
        }
    }
    
    func placeMarker(scene: Scene, color: UIColor) {
        let marker = GMSMarker()
        marker.icon = GMSMarker.markerImage(with: color)
        marker.position = CLLocationCoordinate2DMake(scene.latitude!, scene.longitude!)
        marker.title = scene.name
        marker.userData = scene
        marker.map = mapView
    }
    
    func onDismissed() {
        tripDetailsView.removeFromSuperview()
        blurView.removeFromSuperview()
        xBackButton.removeFromSuperview()
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        obscureBackground()
        tripDetailsView = TripDetailsView.fromNib("TripDetailsView")
        tripDetailsView.delegate = self
        tripDetailsView.size(self)
        tripDetailsView.bindTrip(marker.userData as! Trip)
        view.addSubview(tripDetailsView)
        return true
    }
    
    func segueToContainer() {
        performSegue(withIdentifier: "MapToContainer", sender: self)
    }
    
    func obscureBackground() {
        blurBackground()
        addXBackButton()
    }
    
    func addXBackButton() {
        let frame = CGRect(x: view.bounds.width - 45, y: 30, width: 30, height: 30)
        xBackButton = XBackButton(frame: frame)
        xBackButton.addTarget(self, action: #selector(onDismissed), for: .touchUpInside)
        view.addSubview(xBackButton)
    }
    
    func blurBackground() {
        blurView = BlurView(onClick: onDismissed)
        blurView.frame = view.bounds
        view.addSubview(blurView)
    }

}
