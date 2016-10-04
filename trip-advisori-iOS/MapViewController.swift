//
//  MapViewController.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 1/30/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//

import UIKit
import GoogleMaps

class MapViewController: UIViewController, GMSMapViewDelegate, SocketServiceDelegate, TripDetailsViewDelegate {
    
    fileprivate let currentLocationService:CurrentLocationService = Injector.sharedInjector.getCurrentLocationService()
    fileprivate let socketService: SocketService = Injector.sharedInjector.getSocketService()
    fileprivate let tripsService:TripsService = Injector.sharedInjector.getTripsService()
    
    var trips:[Trip]!
    
    var blurView: BlurView!
    var tripDetailsView:TripDetailsView!
    var xBackButton:XBackButton!
    
    var delegate: MainViewControllerDelegate!
    
    
    @IBAction func openMenu(_ sender: AnyObject) {
        delegate.toggleRightPanel()
    }
    
    @IBOutlet weak var mapView: GMSMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        socketService.registerDelegate(self)
        getTrips()
        configureMapView()
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
        let marker = GMSMarker()
        marker.icon = GMSMarker.markerImage(with: colorForTrip)
        marker.position = CLLocationCoordinate2DMake(trip.scenes![0].latitude!, trip.scenes![0].longitude!)
        marker.title = trip.title
        marker.snippet = trip.descriptionText
        marker.userData = trip
        marker.map = mapView
    }
    
    func onDismissed() {
        tripDetailsView.removeFromSuperview()
        blurView.removeFromSuperview()
        xBackButton.removeFromSuperview()
    }
    
    func onResponseReceived(_ partyState: PartyState) {}
    
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
