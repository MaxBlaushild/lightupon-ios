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
        //TEMP BANNER: Need to grab cover photo from FB? or have people capture one they can upload?
        profileBanner.image = UIImage(named: "banner")
    }

    @IBAction func logout(sender: AnyObject) {
        authService.logout()
        performSegueWithIdentifier("ProfileToLogin", sender: nil)
    }
    
    func bindProfileToView(profile: FacebookProfile){
        profilePic.imageFromUrl(profile.profilePictureURL)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
}
