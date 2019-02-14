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

class LoginViewController: UIViewController, FBSDKLoginButtonDelegate, LoadingAnimationViewDelegate {
    fileprivate let  facebookService:FacebookService = Services.shared.getFacebookService()
    fileprivate let loginService:LoginService = Services.shared.getLoginService()
    fileprivate var loadingAnimation: LoadingAnimationView!
    
    @IBOutlet weak var loginView: FBSDKLoginButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setLoginButton()
        loadingAnimation = LoadingAnimationView.fromNib("LoadingAnimationView")
        loadingAnimation.initialize(parentView: self)
        view.addSubview(loadingAnimation)
        loadingAnimation.animate()
    }
    
    func dismissLoadingView() {}
    
    public func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        
        if ((error) != nil) {
            // Process error
        } else if result.isCancelled {
            // Handle cancellations
        } else {
            loginView.isHidden = true
            facebookService.getMyProfile(self.onLoginInfoRecieved)
        }
    }
    
    override var shouldAutorotate : Bool {
        return false
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
    
    func setLoginButton() {
        loginView.center = CGPoint(x: view.frame.width / 2, y: view.frame.height - 100)
        loginView.readPermissions = ["public_profile", "email", "user_friends"]
        loginView.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("User Logged Out")
    }
    
    func onLoginInfoRecieved(_ profile: FacebookProfile) {
        loginService.upsertUser(profile, callback: self.onLogin)
    }
    
    func onLogin() {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
            self.performSegue(withIdentifier: "LoginToInitial", sender: self)
        }
    }
}
