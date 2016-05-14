//
//  LoginViewController.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 2/13/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import Locksmith

class LoginViewController: UIViewController, FBSDKLoginButtonDelegate {
    private let  profileService:ProfileService = Injector.sharedInjector.getProfileService()
    private let loginService:LoginService = Injector.sharedInjector.getLoginService()

    override func viewDidLoad() {
        super.viewDidLoad()
        setLoginButton()
    }
    
    func setLoginButton() {
        let loginView : FBSDKLoginButton = FBSDKLoginButton()
        self.view.addSubview(loginView)
        loginView.center = self.view.center
        loginView.readPermissions = ["public_profile", "email", "user_friends"]
        loginView.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Facebook Delegate Methods
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        print("User Logged In")
        
        if ((error) != nil) {
            // Process error
        } else if result.isCancelled {
            // Handle cancellations
        } else {
            profileService.getLoginInfo(self.onLoginInfoRecieved)
        }
    }
    

    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        print("User Logged Out")
    }
    
    func onLoginInfoRecieved(profile: FacebookProfile) {
        loginService.upsertUser(profile, callback: self.onLogin)
    }
    
    func onLogin() {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
            self.performSegueWithIdentifier("LoginToInitial", sender: self)
        }
    }
}
