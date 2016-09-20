//
//  EndOfTripView.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 9/4/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//

import UIKit

protocol EndOfTripDelegate {
    func onTripEnds() -> Void
}

class EndOfTripView: UIView {
    private let partyService = Injector.sharedInjector.getPartyService()
    
    var delegate: EndOfTripDelegate!
    
    @IBAction func endTrip(sender: UIButton) {
        sender.enabled = false
        partyService.finishParty(self.goBackHome)
    }
    
    func goBackHome() {
        delegate.onTripEnds()
    }

}
