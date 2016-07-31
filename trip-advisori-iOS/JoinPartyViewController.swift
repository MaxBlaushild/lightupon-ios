//
//  JoinPartyViewController.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 3/25/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//

import UIKit

class JoinPartyViewController: MenuViewController {
    private let partyService:PartyService = Injector.sharedInjector.getPartyService()
    
    @IBOutlet weak var passcodeField: UITextField!
    
    @IBOutlet weak var joinPartyCopy: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addTitle("JOURNEY", color: UIColor.whiteColor())
        // Do any additional setup after loading the view.
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }

    @IBAction func submitPasscode(sender: AnyObject) {
        var passcode:String = passcodeField.text!.removeWhitespace()
        
        if passcode.characters.count == 0 {
            passcode = "a"
        }
        
        partyService.joinParty(passcode, successCallback: self.goToLobby, failureCallback: self.onPartyNotFound)
    }
    
    func goToLobby() {
        self.performSegueWithIdentifier("JoinPartyToLobby", sender: self)
    }
    
    func onPartyNotFound() {
        joinPartyCopy.text = "There is no party with that passcode. Try again!"
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
