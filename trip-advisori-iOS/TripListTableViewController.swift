//
//  TripListTableViewController.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 2/6/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//

import UIKit

private extension UIStoryboard {
    class func mainStoryboard() -> UIStoryboard { return UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()) }
    
    class func tripDetailsViewController() -> TripDetailsViewController? {
        return mainStoryboard().instantiateViewControllerWithIdentifier("TripDetailsViewController") as? TripDetailsViewController
    }
}

class HalfSizePresentationController : UIPresentationController {
    override func frameOfPresentedViewInContainerView() -> CGRect {
        let viewWidth = containerView!.bounds.width / 1.33
        let viewHeight = containerView!.bounds.height / 2
        let xOrigin = (containerView!.bounds.width - viewWidth) / 2
        let yOrigin = (containerView!.bounds.height - viewHeight) / 2
        return CGRect(x: xOrigin, y: yOrigin, width: viewWidth, height: viewHeight)
    }
}

protocol DismissalDelegate {
    func onDismissed() -> Void
}

class TripListTableViewController: UITableViewController, UIViewControllerTransitioningDelegate, DismissalDelegate {
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
    
    func presentationControllerForPresentedViewController(presented: UIViewController, presentingViewController presenting: UIViewController, sourceViewController source: UIViewController) -> UIPresentationController? {
        return HalfSizePresentationController(presentedViewController: presented, presentingViewController: presentingViewController!)
    }
    
    func onDismissed() {
        for subview in self.view.subviews {
            if let blur = subview as? UIVisualEffectView {
                blur.removeFromSuperview()
            }
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        blurBackground()
        let tripDetailsViewController = UIStoryboard.tripDetailsViewController()
        tripDetailsViewController!.modalPresentationStyle = UIModalPresentationStyle.Custom
        tripDetailsViewController!.transitioningDelegate = self
        tripDetailsViewController!.dismissalDelegate = self
        tripDetailsViewController!.tripId = trips[indexPath.row].id
        self.presentViewController(tripDetailsViewController!, animated: true, completion: {})
    }
    
    func blurBackground() {
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight] // for supporting device rotation
        view.addSubview(blurEffectView)
    }

}
