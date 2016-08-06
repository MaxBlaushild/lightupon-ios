//
//  LobbyViewController.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 2/29/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//

import UIKit

class TripDetailsViewController: UIViewController, SocketServiceDelegate {
    private let tripsService: TripsService = Injector.sharedInjector.getTripsService()
    private let partyService: PartyService = Injector.sharedInjector.getPartyService()
    private let socketService: SocketService = Injector.sharedInjector.getSocketService()
    
    var trip:Trip!
    var tripId:Int!
    var partyState: PartyState!
    var currentParty: Party!
    var dismissalDelegate: DismissalDelegate!
    var waitingForPartyState: Bool = false

    @IBOutlet weak var tripTitle: UILabel!
    @IBOutlet weak var tripDetailsLabel: UILabel!
    @IBOutlet weak var tripDetailsPicture: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        socketService.delegate = self
        tripsService.getTrip(tripId, vc: self)
    }

    @IBAction func createParty(sender: AnyObject) {
        partyService.createParty(trip.id, callback: self.onPartyCreated)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func goBack(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: {});
        dismissalDelegate.onDismissed()
    }
    
    func onPartyCreated(party: Party) {
        currentParty = party
        waitingForPartyState = true
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
    func segueToStoryTeller() {
        self.performSegueWithIdentifier("DetailsToStoryTeller", sender: self)
    }
    
    func onResponseRecieved(_partyState_: PartyState) {
        partyState = _partyState_
        
        if (waitingForPartyState) {
            segueToStoryTeller()
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let destinationVC = segue.destinationViewController as? StoryTellerContainerViewController {
            destinationVC.partyState = partyState
            destinationVC.currentParty = currentParty
        }
    }

}
