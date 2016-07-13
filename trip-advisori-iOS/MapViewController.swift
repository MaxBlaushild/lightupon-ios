//
//  MapViewController.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 1/30/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//

import UIKit
import GoogleMaps

class MapViewController: MenuViewController {
    private let currentLocationService:CurrentLocationService = Injector.sharedInjector.getCurrentLocationService()
    
    var trips:[Trip]!

    @IBOutlet weak var mapView: GMSMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
        initMap()
        addTitle("SERENDIPITY", color: Colors.basePurple)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initMap() {
        for trip in trips {
            placeTripOnMap(trip, mapView: mapView)
        }
    }
    
    func placeTripOnMap(trip: Trip, mapView: GMSMapView) {
        let marker = GMSMarker()
        
        marker.position = CLLocationCoordinate2DMake(trip.latitude, trip.longitude)
        marker.title = trip.title
        marker.snippet = trip.descriptionText
        marker.map = mapView
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
