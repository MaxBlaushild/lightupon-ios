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
    class func mainStoryboard() -> UIStoryboard { return UIStoryboard(name: "Main", bundle: Bundle.main) }
    
    class func loginViewController() -> LoginViewController? {
        return mainStoryboard().instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController
    }
    
    class func mainContainerViewController() -> MainContainerViewController? {
        return mainStoryboard().instantiateViewController(withIdentifier: "MainContainerViewController") as? MainContainerViewController
    }
}

class InitialLoadingViewController: UIViewController {
    fileprivate let authService: AuthService = Injector.sharedInjector.getAuthService()
    fileprivate let userService: UserService = Injector.sharedInjector.getUserService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeUser()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override var shouldAutorotate : Bool {
        return false
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
    
    func initializeUser() {
        let loggedIn = authService.userIsLoggedIn()
        
        if (loggedIn) {
            userService.getMyself(successCallback: self.onMyselfRetrieved)
        } else {
            routeTo("InitialToLogin")
        }
    }
    
    func routeTo(_ segue: String){
        if (segue == "InitialToLogin") {
            presentLoginViewController()
        } else {
            presentMainContainerViewController()
        }
    }
    
    func presentLoginViewController() {
        OperationQueue.main.addOperation {
            self.performSegue(withIdentifier: "InitialToLogin", sender: nil)
        }
        
    }
    
    func presentMainContainerViewController() {
        let mainContainerViewController = UIStoryboard.mainContainerViewController()
        self.present(mainContainerViewController!, animated: false, completion: nil)
        mainContainerViewController?.didMove(toParentViewController: self)
    }
    
    func onMyselfRetrieved() {
        routeTo("InitialToContainer")
    }
}
