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
        UITabBar.appearance().barTintColor = UIColor.whiteColor()
        for tabBarItem in tabBar.items! {
            tabBarItem.title = ""
            tabBarItem.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0)
        }
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
