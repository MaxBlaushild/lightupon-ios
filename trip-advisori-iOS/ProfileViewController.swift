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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profileService.getProfile(self.bindProfileToView)
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
        // Dispose of any resources that can be recreated.
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
