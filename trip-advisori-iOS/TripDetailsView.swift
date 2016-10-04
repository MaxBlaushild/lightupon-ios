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
    fileprivate let tripsService: TripsService = Injector.sharedInjector.getTripsService()
    fileprivate let partyService: PartyService = Injector.sharedInjector.getPartyService()
    
    fileprivate var _trip:Trip!
    
    internal var delegate: TripDetailsViewDelegate!
    
    @IBOutlet weak var tripDetailsLabel: UILabel!
    @IBOutlet weak var tripDetailsPicture: UIImageView!
    
    func size(_ viewController: UIViewController) {
        let tripDetailsHeight = viewController.view.frame.height * 0.6
        let tripDetailsWidth = viewController.view.frame.width * 0.8
        frame = CGRect(x: viewController.view.frame.width / 2 - tripDetailsWidth / 2, y:viewController.view.frame.height / 2 - tripDetailsHeight / 2, width: tripDetailsWidth, height: tripDetailsHeight)
        roundCorners()
    }
    
    func bindTrip(_ trip: Trip) {
        _trip = trip
        tripDetailsLabel.text = trip.descriptionText
        tripDetailsPicture.imageFromUrl(trip.imageUrl!)
    }
    
    @IBAction func createParty(_ sender: UIButton) {
        sender.isEnabled = false
        partyService.createParty(_trip.id!, callback: self.onPartyCreated)
        
    }
    
    func onPartyCreated() {
        delegate.segueToContainer()
    }
    
    func shouldAutorotate() -> Bool {
        return false
    }
    
    func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }


}
