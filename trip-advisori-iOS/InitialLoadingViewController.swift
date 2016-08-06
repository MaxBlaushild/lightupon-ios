//
//  InitialLoadingViewController.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 2/1/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//

import UIKit

class InitialLoadingViewController: UIViewController, SocketServiceDelegate {
    private let socketService: SocketService = Injector.sharedInjector.getSocketService()
    private let authService: AuthService = Injector.sharedInjector.getAuthService()
    private let partyService: PartyService = Injector.sharedInjector.getPartyService()
    private let profileService: ProfileService = Injector.sharedInjector.getProfileService()
    
    var waitingForPartyState: Bool = false
    var partyState: PartyState!
    var currentParty: Party!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        socketService.delegate = self
        initializeUser()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
    func initializeUser() {
        let loggedIn = authService.userIsLoggedIn()
        
        if (loggedIn) {
            profileService.getMyProfile(self.checkIfUserIsInParty)
        } else {
            routeTo("InitialToLogin")
        }
    }
    
    func routeTo(segue: String){
        dispatch_async(dispatch_get_main_queue()){
            self.performSegueWithIdentifier(segue, sender: nil)
        }
    }
    
    func checkIfUserIsInParty(_: FacebookProfile) {
        partyService.getUsersParty(self.onPartyGotten)
    }
    
    func onPartyGotten(party: Party) {
        if (party.id == 0) {
            routeTo("LoadingToTabs")
        } else {
            currentParty = party
            waitingForPartyState = true
        }
    }
    
    func onResponseRecieved(_partyState_: PartyState) {
        partyState = _partyState_
        
        if (waitingForPartyState && partyState.scene!.id != 0) {
            routeTo("InitialToStoryTeller")
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let destinationVC = segue.destinationViewController as? StoryTellerContainerViewController {
            destinationVC.partyState = partyState
            destinationVC.currentParty = currentParty
        }
    }
}
