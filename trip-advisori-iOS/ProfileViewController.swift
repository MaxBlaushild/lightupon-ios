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
    
    var profileView: ProfileView!
    var litButton: LitButton!

    @IBAction func goBack(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: {});
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        litButton.bindLitness()
        if let profileView = profileView {
            profileView.refresh()
        }
    }
    
    func initProfile() {
        profileView = ProfileView.fromNib("ProfileView")
        litButton = LitButton(frame: CGRect(
            x: self.view.frame.width - 45,
            y: 32,
            width: 25,
            height: 25))
        profileView.frame = view.frame
        profileView.delegate = self
        profileView.initializeView(userService.currentUser)
        view.addSubview(profileView)
        view.addSubview(litButton)
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
