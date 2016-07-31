//
//  LobbyViewController.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 2/29/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//

import UIKit

class TripDetailsViewController: UIViewController {
    private let tripsService: TripsService = Injector.sharedInjector.getTripsService()
    private let partyService: PartyService = Injector.sharedInjector.getPartyService()
    
    var trip:Trip!
    var tripId:Int!

    @IBOutlet weak var tripTitle: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tripsService.getTrip(tripId, vc: self)
    }

    @IBAction func createParty(sender: AnyObject) {
        partyService.createParty(trip.id, callback: self.goToLobby)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
    func goToLobby() {
        self.performSegueWithIdentifier("DetailsToLobby", sender: self)
    }

}
