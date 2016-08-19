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

class TripListTableViewController: UIViewController, UIViewControllerTransitioningDelegate, DismissalDelegate, UITableViewDelegate, UITableViewDataSource, SocketServiceDelegate {
    private let tripsService: TripsService = Injector.sharedInjector.getTripsService()
    
    var trips:[Trip]!
    var delegate: MainViewControllerDelegate!

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
        tripsService.getTrips(self.onTripsGotten)
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
    
    func onResponseReceived(partyState: PartyState) {}
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
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
