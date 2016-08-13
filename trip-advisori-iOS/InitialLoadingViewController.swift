//
//  InitialLoadingViewController.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 2/1/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//

import UIKit

class InitialLoadingViewController: UIViewController {
    private let authService: AuthService = Injector.sharedInjector.getAuthService()
    private let profileService: ProfileService = Injector.sharedInjector.getProfileService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeUser()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
    func initializeUser() {
        let loggedIn = authService.userIsLoggedIn()
        
        if (loggedIn) {
            profileService.getMyProfile(self.onProfileGotten)
        } else {
            routeTo("InitialToLogin")
        }
    }
    
    func routeTo(segue: String){
        dispatch_async(dispatch_get_main_queue()){
            self.performSegueWithIdentifier(segue, sender: nil)
        }
    }
    
    func onProfileGotten(_: FacebookProfile) {
        routeTo("InitialToContainer")
    }
}
