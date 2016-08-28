//
//  InitialLoadingViewController.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 2/1/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//

import UIKit
import CBZSplashView

private extension UIStoryboard {
    class func mainStoryboard() -> UIStoryboard { return UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()) }
    
    class func loginViewController() -> LoginViewController? {
        return mainStoryboard().instantiateViewControllerWithIdentifier("LoginViewController") as? LoginViewController
    }
    
    class func mainContainerViewController() -> MainContainerViewController? {
        return mainStoryboard().instantiateViewControllerWithIdentifier("MainContainerViewController") as? MainContainerViewController
    }
}

class InitialLoadingViewController: UIViewController {
    private let authService: AuthService = Injector.sharedInjector.getAuthService()
    private let profileService: ProfileService = Injector.sharedInjector.getProfileService()
    
    @IBOutlet weak var splashImage: UIImageView!
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
        if (segue == "InitialToLogin") {
            presentLoginViewController()
        } else {
            presentMainContainerViewController()
        }
    }
    
    func presentLoginViewController() {
        let loginViewController = UIStoryboard.loginViewController()
        self.presentViewController(loginViewController!, animated: false, completion: nil)
        view.addSubview(loginViewController!.view)
        loginViewController?.didMoveToParentViewController(self)
        self.view.splashView()
    }
    
    func presentMainContainerViewController() {
        let mainContainerViewController = UIStoryboard.mainContainerViewController()
        self.presentViewController(mainContainerViewController!, animated: false, completion: nil)
        mainContainerViewController?.didMoveToParentViewController(self)
    }
    
    func onProfileGotten(_: FacebookProfile) {
        routeTo("InitialToContainer")
    }
}
