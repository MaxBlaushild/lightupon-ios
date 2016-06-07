//
//  HomeTabBarViewController.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 2/1/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//

import UIKit

class HomeTabBarViewController: UITabBarController {
    private let tripsService: TripsService = Injector.sharedInjector.getTripsService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tripsService.getTrips(self.setTrips)
    }

    
    func setTrips(trips: [Trip]) {
        for controller in viewControllers! {
            
            if let mapController = controller as? MapViewController {
                mapController.trips = trips
            }
            
            if let tableController = controller as? TripListTableViewController {
                tableController.trips = trips
                tableController.tableView.reloadData()
            }
        }
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
