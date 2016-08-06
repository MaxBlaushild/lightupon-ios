//
//  TripListTableViewController.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 2/6/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//

import UIKit

class TripListTableViewController: UITableViewController {
    var trips:[Trip]!
    private let  tripListTableViewCellDecorator:TripListTableViewCellDecorator = TripListTableViewCellDecorator()

    override func viewDidLoad() {
        super.viewDidLoad()
        setTripsIfNotSet()
        style()
        addTitle()
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
    func setTripsIfNotSet(){
        if trips == nil {
            trips = []
        }
    }
    
    func style() {
        self.tableView.contentInset = UIEdgeInsetsMake(90, 0, 0, 0);
        self.view.backgroundColor = Colors.basePurple
    }
    
    func addTitle() {
        let label = UILabel(frame: CGRectMake(0, 0, 200, 40))
        label.center = CGPointMake(60, -40)
        label.textAlignment = NSTextAlignment.Center
        label.text = "TRIPS"
        label.font = UIFont(name: Fonts.dosisExtraLight, size: 38)
        label.textColor = UIColor.whiteColor()
        self.view.addSubview(label)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        
            return trips.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> TripListTableViewCell {
        let cell:TripListTableViewCell = tableView.dequeueReusableCellWithIdentifier("tripListTableViewCell", forIndexPath: indexPath) as! TripListTableViewCell

        tripListTableViewCellDecorator.decorateCell(cell, trip: trips[indexPath.row])
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        let tripDetailsViewController = TripDetailsViewController()
        tripDetailsViewController.tripId = trips[indexPath.row].id
        tripDetailsViewController.view.frame = self.view.frame
//        tripDetailsViewController.modalPresentationStyle = .OverCurrentContext
        self.presentViewController(tripDetailsViewController, animated: true, completion: {})
    }


}
