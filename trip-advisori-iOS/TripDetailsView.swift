//
//  TripDetailsView.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 9/11/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//

import UIKit

protocol TripDetailsViewDelegate {
    func segueToContainer() -> Void
}

class TripDetailsView: UIView {
    private let tripsService: TripsService = Injector.sharedInjector.getTripsService()
    private let partyService: PartyService = Injector.sharedInjector.getPartyService()
    
    private var _trip:Trip!
    
    internal var delegate: TripDetailsViewDelegate!
    
    @IBOutlet weak var tripDetailsLabel: UILabel!
    @IBOutlet weak var tripDetailsPicture: UIImageView!
    
    func size(viewController: UIViewController) {
        let tripDetailsHeight = viewController.view.frame.height * 0.6
        let tripDetailsWidth = viewController.view.frame.width * 0.8
        frame = CGRect(x: viewController.view.frame.width / 2 - tripDetailsWidth / 2, y:viewController.view.frame.height / 2 - tripDetailsHeight / 2, width: tripDetailsWidth, height: tripDetailsHeight)
        roundCorners()
    }
    
    func roundCorners() {
        layer.cornerRadius = 6
        layer.masksToBounds = true
    }
    
    func bindTrip(trip: Trip) {
        _trip = trip
        tripDetailsLabel.text = trip.descriptionText
        tripDetailsPicture.imageFromUrl(trip.imageUrl!)
    }
    
    @IBAction func createParty(sender: AnyObject) {
        partyService.createParty(_trip.id!, callback: self.onPartyCreated)
        
    }
    
    func onPartyCreated() {
        
        delegate.segueToContainer()
    }
    
    func shouldAutorotate() -> Bool {
        return false
    }
    
    func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }


}
