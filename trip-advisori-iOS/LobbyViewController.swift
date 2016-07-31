//
//  LobbyViewController.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 3/27/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//

import UIKit
import AVFoundation

class LobbyViewController: UIViewController, SocketServiceDelegate {
    private let partyService: PartyService = Injector.sharedInjector.getPartyService()
    private let socketService: SocketService = Injector.sharedInjector.getSocketService()
    private let alertService: AlertService = Injector.sharedInjector.getAlertService()
    
    var partyState: PartyState!
    var currentParty: Party!
    
    var coinSound = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("TestSound2", ofType: "mp3")!)
    var audioPlayer = AVAudioPlayer()

    @IBOutlet weak var startPartyButton: UIButton!
    @IBOutlet weak var passcodeLabel: UILabel!
    @IBOutlet weak var tripTitle: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        socketService.delegate = self
        partyService.getUsersParty(self.processParty)
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
    @IBAction func playSound(sender: AnyObject) {
        do {
            try audioPlayer = AVAudioPlayer(contentsOfURL: coinSound, fileTypeHint: nil)
        } catch _ { }
        audioPlayer.prepareToPlay()
        audioPlayer.play()
    }
    
    @IBAction func startParty(sender: AnyObject) {
        partyService.startNextScene(currentParty.id)
    }
    
    @IBAction func leaveParty(sender: AnyObject) {
        partyService.leaveParty(self.onPartyLeft)
    }
    
    func getParty() {
        partyService.getUsersParty(self.processParty)
    }
    
    func processParty(party: Party) {
        currentParty = party
        passcodeLabel.text = currentParty.passcode
        tripTitle.text = currentParty.trip.title
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
        if let destinationVC = segue.destinationViewController as? StoryTellerContainerViewController {
            destinationVC.partyState = partyState
            destinationVC.currentParty = currentParty
        }
    }
}
