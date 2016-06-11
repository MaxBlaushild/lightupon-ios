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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addTitle("JOURNEY", color: UIColor.whiteColor())
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func submitPasscode(sender: AnyObject) {
        let passcode:String = passcodeField.text!
        partyService.joinParty(passcode, callback: self.goToLobby)
    }
    
    func goToLobby() {
        self.performSegueWithIdentifier("JoinPartyToLobby", sender: self)
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
