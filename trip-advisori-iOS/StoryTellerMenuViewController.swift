//
//  StoryTellerMenuViewController.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 7/5/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//

import UIKit

class StoryTellerMenuViewController: UIViewController {
    let partyService: PartyService = Injector.sharedInjector.getPartyService()
    let profileService: ProfileService = Injector.sharedInjector.getProfileService()

    @IBOutlet weak var profilePicture: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        profilePicture.imageFromUrl(profileService.profile.profilePictureURL)
        self.profilePicture.makeCircle()
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

    func goBack(){
        dismissViewControllerAnimated(true, completion: {})
    }
    
    @IBAction func leaveParty(sender: AnyObject) {
        partyService.leaveParty({
            self.performSegueWithIdentifier("StoryTellerMenuToHome", sender: nil)
        })
    }
}
