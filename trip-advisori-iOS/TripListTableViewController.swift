//
//  TripListTableViewController.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 2/6/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//

import UIKit

class TripListTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, TripDetailsViewDelegate {
    private let tripsService: TripsService = Injector.sharedInjector.getTripsService()
    private let currentLocationService:CurrentLocationService = Injector.sharedInjector.getCurrentLocationService()
    
    var trips:[Trip]!
    var delegate: MainViewControllerDelegate!
    
    var tripDetailsView:TripDetailsView!
    var blurView: BlurView!
    var xBackButton: XBackButton!

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getTrips()
    }
    
    func configureTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        tableView.reloadData()
    }
    
    func getTrips() {
        tripsService.getTrips(self.onTripsGotten, latitude: self.currentLocationService.latitude, longitude: self.currentLocationService.longitude)
    }
    
    func onTripsGotten(_trips_: [Trip]) {
        trips = _trips_
        configureTableView()
    }
    
    @IBAction func openMenu(sender: AnyObject) {
        delegate!.toggleRightPanel()
    }
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trips.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:TripListTableViewCell = tableView.dequeueReusableCellWithIdentifier("tripListTableViewCell", forIndexPath: indexPath) as! TripListTableViewCell

        cell.decorateCell(trips[indexPath.row])
        
        return cell
    }
    
    func dismissTripDetails() {
        tripDetailsView.removeFromSuperview()
        blurView.removeFromSuperview()
        xBackButton.removeFromSuperview()
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        obfuscateBackground()
        tripDetailsView = TripDetailsView.fromNib("TripDetailsView")
        tripDetailsView.delegate = self
        tripDetailsView.size(self)
        tripDetailsView.bindTrip(trips[indexPath.row])
        view.addSubview(tripDetailsView)
    }
    
    func obfuscateBackground() {
        blurBackground()
        addXBackButton()
    }
    
    func segueToContainer() {
        performSegueWithIdentifier("ListToContainer", sender: self)
    }
    
    func blurBackground() {
        blurView = BlurView(onClick: dismissTripDetails)
        blurView.frame = view.bounds
        view.addSubview(blurView)
    }
    
    func addXBackButton() {
        let frame = CGRect(x: view.bounds.width - 45, y: 30, width: 30, height: 30)
        xBackButton = XBackButton(frame: frame)
        xBackButton.addTarget(self, action: #selector(dismissTripDetails), forControlEvents: .TouchUpInside)
        view.addSubview(xBackButton)
    }

}
