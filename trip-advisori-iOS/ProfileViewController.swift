//
//  ProfileViewController.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 2/15/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class ProfileViewController: UIViewController, ProfileViewDelegate {
    private let profileService: ProfileService = Injector.sharedInjector.getProfileService()

    
    @IBAction func goBack(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: {});
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        profileService.getMyProfile(self.bindProfileToView)
    }
    
    func onLoggedOut() {
        performSegueWithIdentifier("ProfileToLogin", sender: nil)
    }
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
    func bindProfileToView(profile: FacebookProfile){
        let profileView = ProfileView.fromNib("ProfileView")
        profileView.frame = view.frame
        profileView.delegate = self
        profileView.initializeView(profile)
        view.addSubview(profileView)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
}
