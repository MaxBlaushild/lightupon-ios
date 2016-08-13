//
//  ProfileViewController.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 2/15/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class ProfileViewController: UIViewController {
    private let authService: AuthService = Injector.sharedInjector.getAuthService()
    private let profileService: ProfileService = Injector.sharedInjector.getProfileService()

    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var profileBanner: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        profileService.getMyProfile(self.bindProfileToView)
    }
    
    @IBAction func logOut(sender: AnyObject) {
        authService.logout()
        performSegueWithIdentifier("ProfileToLogin", sender: nil)
    }
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
    func bindProfileToView(profile: FacebookProfile){
        profileBanner.imageFromUrl(profile.coverPhoto!)
        profilePic.imageFromUrl(profile.profilePictureURL!)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
}
