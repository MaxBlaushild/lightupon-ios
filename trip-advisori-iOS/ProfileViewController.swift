//
//  ProfileViewController.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 2/15/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class ProfileViewController: TripModalPresentingViewController, ProfileViewDelegate {
    
    fileprivate let userService: UserService = Services.shared.getUserService()
    
    @IBOutlet weak var tabBar: UIView!
    @IBOutlet weak var litButton: LitButton!
    
    var profileView: ProfileView!

    @IBAction func goBack(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: {});
    }
    
    override func viewDidAppear(_ animated: Bool) {
        litButton.delegate = self
        
        if let profileView = profileView {
            profileView.refresh()
        }
    }
    
    func initProfile() {
        profileView = ProfileView.fromNib("ProfileView")
        profileView.frame = view.frame
        profileView.delegate = self
        profileView.initializeView(userService.currentUser.id)
        view.addSubview(profileView)
        view.bringSubview(toFront: tabBar)
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
