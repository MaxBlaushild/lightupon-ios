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

    public func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        print("User Logged In")
        
        if ((error) != nil) {
            // Process error
        } else if result.isCancelled {
            // Handle cancellations
        } else {
            loginView.isHidden = true
            profileService.getLoginInfo(self.onLoginInfoRecieved)
        }
    }

    fileprivate let  profileService:ProfileService = Injector.sharedInjector.getProfileService()
    fileprivate let loginService:LoginService = Injector.sharedInjector.getLoginService()

    @IBOutlet weak var loginView: FBSDKLoginButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        setLoginButton()
        addFrame()
    }
    
    func addFrame() {
        let offset = view.frame.width / 10
        let size = CGSize(width: view.frame.width - offset * 2, height: view.frame.height - offset * 2)
        let imageView = UIImageView(frame: CGRect(origin: CGPoint(x: offset, y: offset), size: size))
        self.view.addSubview(imageView)
        imageView.image = UIImage.frame(size, color: UIColor.white.cgColor)
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
