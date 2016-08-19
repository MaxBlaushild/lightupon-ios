//
//  MapViewController.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 1/30/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//

import UIKit
import GoogleMaps

private extension UIStoryboard {
    class func mainStoryboard() -> UIStoryboard { return UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()) }
    
    class func tripDetailsViewController() -> TripDetailsViewController? {
        return mainStoryboard().instantiateViewControllerWithIdentifier("TripDetailsViewController") as? TripDetailsViewController
    }
}

class MapViewController: UIViewController, GMSMapViewDelegate, DismissalDelegate, SocketServiceDelegate, UIViewControllerTransitioningDelegate {
    private let currentLocationService:CurrentLocationService = Injector.sharedInjector.getCurrentLocationService()
    private let tripsService:TripsService = Injector.sharedInjector.getTripsService()
    
    var trips:[Trip]!
    
    var delegate: MainViewControllerDelegate!
    
    
    @IBAction func openMenu(sender: AnyObject) {
        delegate.toggleRightPanel()
    }
    
    @IBOutlet weak var mapView: GMSMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
        getTrips()
        mapView.camera = GMSCameraPosition.cameraWithLatitude(currentLocationService.latitude, longitude: currentLocationService.longitude, zoom: 15)
        mapView.myLocationEnabled = true
        mapView.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
    func getTrips() {
        tripsService.getTrips(self.onTripsGotten)
    }
    
    func onTripsGotten(_trips_: [Trip]) {
        trips = _trips_
        initMap()
    }
    
    func initMap() {
        for trip in trips {
            placeTripOnMap(trip, mapView: mapView)
        }
    }
    
    func placeTripOnMap(trip: Trip, mapView: GMSMapView) {
        let marker = GMSMarker()
        
        marker.position = CLLocationCoordinate2DMake(trip.latitude!, trip.longitude!)
        marker.title = trip.title
        marker.snippet = trip.descriptionText
        marker.userData = trip.id
        marker.map = mapView
    }
    
    func onDismissed() {
        for subview in self.view.subviews {
            if let blur = subview as? UIVisualEffectView {
                blur.removeFromSuperview()
            }
        }
    }
    
    func onResponseReceived(partyState: PartyState) {}
    
    func mapView(mapView: GMSMapView, didTapMarker marker: GMSMarker) -> Bool {
        blurBackground()
        let tripDetailsViewController = UIStoryboard.tripDetailsViewController()
        tripDetailsViewController!.modalPresentationStyle = UIModalPresentationStyle.Custom
        tripDetailsViewController!.transitioningDelegate = self
        tripDetailsViewController!.dismissalDelegate = self
        tripDetailsViewController!.tripId = marker.userData as! Int
        self.presentViewController(tripDetailsViewController!, animated: true, completion: {})
        
        return true
    }
    
    func blurBackground() {
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight] // for supporting device rotation
        view.addSubview(blurEffectView)
    }
    
    func presentationControllerForPresentedViewController(presented: UIViewController, presentingViewController presenting: UIViewController, sourceViewController source: UIViewController) -> UIPresentationController? {
        return HalfSizePresentationController(presentedViewController: presented, presentingViewController: presentingViewController!)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
