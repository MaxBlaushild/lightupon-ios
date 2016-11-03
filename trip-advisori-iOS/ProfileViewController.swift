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
    
    fileprivate let userService: UserService = Injector.sharedInjector.getUserService()

    @IBAction func goBack(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: {});
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func initProfile() {
        let profileView = ProfileView.fromNib("ProfileView")
        profileView.frame = view.frame
        profileView.delegate = self
        profileView.initializeView(userService.currentUser)
        view.addSubview(profileView)
    }
    
    func onLoggedOut() {
        performSegue(withIdentifier: "ProfileToLogin", sender: nil)
    }
    override var shouldAutorotate : Bool {
        return false
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
}
