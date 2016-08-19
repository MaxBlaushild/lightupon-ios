//
//  HomeTabBarViewController.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 2/1/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//

import UIKit

class HomeTabBarViewController: UITabBarController, SocketServiceDelegate {
    private let tripsService: TripsService = Injector.sharedInjector.getTripsService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        tripsService.getTrips(self.setTrips)
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
    func assignDelegation(vc: MainContainerViewController) {
        for controller in viewControllers! {
            
            if let mapController = controller as? MapViewController {
                mapController.delegate = vc
            }
            
            if let tableController = controller as? TripListTableViewController {
                tableController.delegate = vc
            }
        }
    }
    
    func onResponseReceived(partyState: PartyState) {
        for controller in viewControllers! {   
            if let vc = controller as? SocketServiceDelegate {
                vc.onResponseReceived(partyState)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
