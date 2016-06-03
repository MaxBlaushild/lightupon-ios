//
//  LobbyViewController.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 3/27/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//

import UIKit

class LobbyViewController: UIViewController, SocketServiceDelegate {
    private let partyService: PartyService = Injector.sharedInjector.getPartyService()
    private let socketService: SocketService = Injector.sharedInjector.getSocketService()
    private let alertService: AlertService = Injector.sharedInjector.getAlertService()
    
    var partyState: PartyState!
    var currentParty: Party!

    @IBOutlet weak var passcodeLabel: UILabel!
    @IBOutlet weak var startPartyButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        socketService.delegate = self
        partyService.getUsersParty(self.processParty)
    }
    
    @IBAction func startParty(sender: AnyObject) {
        partyService.startNextScene(currentParty.id)
    }
    
    @IBAction func leaveParty(sender: AnyObject) {
        partyService.leaveParty(currentParty.id, callback: self.onPartyLeft)
    }
    
    func getParty() {
        partyService.getUsersParty(self.processParty)
    }
    
    func processParty(party: Party) {
        currentParty = party
        passcodeLabel.text = currentParty.passcode
        socketService.openSocket(currentParty.passcode)
    }
    
    func onResponseRecieved(_partyState_: PartyState) {
        partyState = _partyState_
        
        if (partyState.scene?.id != 0) {
            segueToStoryTeller()
        } else if (partyState.nextSceneAvailable!) {
            activateStartPartyButton()
        }
    }
    
    func segueToStoryTeller() {
        performSegueWithIdentifier("LobbyToStoryTeller", sender: nil)
    }
    
    func activateStartPartyButton() {
        startPartyButton.enabled = true
    }
    
    func openAlert(title: String, message: String) {
        alertService.openAlert(title, message: message, view: self)
    }
    
    func onPartyLeft() {
        self.performSegueWithIdentifier("LobbyToHome", sender: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let destinationVC = segue.destinationViewController as? StoryTellerViewController {
            socketService.delegate = destinationVC
            destinationVC.partyState = partyState
            destinationVC.currentParty = currentParty
        }
    }
}
