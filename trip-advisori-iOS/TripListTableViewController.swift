//
//  TripListTableViewController.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 2/6/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//

import UIKit

class TripListTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, TripDetailsViewDelegate {
    fileprivate let tripsService: TripsService = Injector.sharedInjector.getTripsService()
    fileprivate let currentLocationService:CurrentLocationService = Injector.sharedInjector.getCurrentLocationService()
    
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
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        tableView.reloadData()
    }
    
    func getTrips() {
        tripsService.getTrips(self.onTripsGotten, latitude: self.currentLocationService.latitude, longitude: self.currentLocationService.longitude)
    }
    
    func onTripsGotten(_ _trips_: [Trip]) {
        trips = _trips_
        configureTableView()
    }
    
    @IBAction func openMenu(_ sender: AnyObject) {
        delegate!.toggleRightPanel()
    }
    override var shouldAutorotate : Bool {
        return false
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trips.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:TripListTableViewCell = tableView.dequeueReusableCell(withIdentifier: "tripListTableViewCell", for: indexPath) as! TripListTableViewCell
        let trip = trips[(indexPath as NSIndexPath).row]
        let pictureUrl = trip.owner?.profilePictureURL!
        
        cell.profileImage.imageFromUrl(pictureUrl!, success: { img in
            cell.profileImage.image = img
            cell.profileImage.makeCircle()
        })
        
        cell.tripImage.imageFromUrl(trip.imageUrl!)
        cell.decorateCell(trip)
        
        return cell
    }
    
    func dismissTripDetails() {
        tripDetailsView.removeFromSuperview()
        blurView.removeFromSuperview()
        xBackButton.removeFromSuperview()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        obfuscateBackground()
        tripDetailsView = TripDetailsView.fromNib("TripDetailsView")
        tripDetailsView.delegate = self
        tripDetailsView.size(self)
        tripDetailsView.bindTrip(trips[(indexPath as NSIndexPath).row])
        view.addSubview(tripDetailsView)
    }
    
    func obfuscateBackground() {
        blurBackground()
        addXBackButton()
    }
    
    func segueToContainer() {
        performSegue(withIdentifier: "ListToContainer", sender: self)
    }
    
    func blurBackground() {
        blurView = BlurView(onClick: dismissTripDetails)
        blurView.frame = view.bounds
        view.addSubview(blurView)
    }
    
    func addXBackButton() {
        let frame = CGRect(x: view.bounds.width - 45, y: 30, width: 30, height: 30)
        xBackButton = XBackButton(frame: frame)
        xBackButton.addTarget(self, action: #selector(dismissTripDetails), for: .touchUpInside)
        view.addSubview(xBackButton)
    }

}
