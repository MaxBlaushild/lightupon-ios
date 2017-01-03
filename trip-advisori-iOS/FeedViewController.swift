//
//  TripListTableViewController.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 2/6/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//

import UIKit

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, TripDetailsViewDelegate {
    fileprivate let tripsService: TripsService = Injector.sharedInjector.getTripsService()
    fileprivate let currentLocationService:CurrentLocationService = Injector.sharedInjector.getCurrentLocationService()
    fileprivate let feedService = Injector.sharedInjector.getFeedService()
    
    var trips:[Trip]!
    var _scenes:[Scene] = [Scene]()
    var delegate: MainViewControllerDelegate!
    
    var blurView: BlurView!
    var xBackButton: XBackButton!

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
//        getTrips()
        getFeed()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getFeed()
    }
    
    func configureTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
    }
    
    func getTrips() {
        tripsService.getTrips(self.onTripsGotten, latitude: self.currentLocationService.latitude, longitude: self.currentLocationService.longitude)
    }
    
    func getFeed() {
        feedService.getFeed(success: self.onFeedGotten)
    }
    
    func onFeedGotten(scenes: [Scene]) {
        _scenes = scenes
        tableView.reloadData()
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
        return _scenes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:TripListTableViewCell = tableView.dequeueReusableCell(withIdentifier: "tripListTableViewCell", for: indexPath) as! TripListTableViewCell
        let scene = _scenes[(indexPath as NSIndexPath).row]
        let pictureUrl = scene.trip?.owner?.profilePictureURL!
        cell.decorateCell(scene: scene)
        cell.profileImage.imageFromUrl(pictureUrl!, success: { img in
            cell.profileImage.image = img
            cell.profileImage.makeCircle()
        })
        
        cell.tripImage.imageFromUrl(scene.cards[0].imageUrl!)

        
        return cell
    }
    
//    func dismissTripDetails() {
//        tripDetailsView.removeFromSuperview()
//        blurView.removeFromSuperview()
//        xBackButton.removeFromSuperview()
//    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        let scene: Scene = _scenes[indexPath.row]
        let tripDetailsViewController = TripDetailsViewController(scene: scene)
        addChildViewController(tripDetailsViewController)
        tripDetailsViewController.view.frame = view.frame
        view.addSubview(tripDetailsViewController.view)
        tripDetailsViewController.didMove(toParentViewController: self)
    }
    
    func segueToContainer() {
        performSegue(withIdentifier: "ListToContainer", sender: self)
    }

}
