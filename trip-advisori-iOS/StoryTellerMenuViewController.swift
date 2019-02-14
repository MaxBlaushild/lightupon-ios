//
//  StoryTellerMenuViewController.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 7/5/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//

import UIKit

class StoryTellerMenuViewController: UIViewController, ProfileViewDelegate {
    
    fileprivate let userService: UserService = Services.shared.getUserService()

    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var levelLabel: UILabel!
    
    fileprivate var _partyState: SocketResponse!
    fileprivate var _party: Party!
    
    fileprivate var profileView: ProfileView!
    fileprivate var xBackButton:XBackButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindProfile()
//        makeProfileClickable()
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var shouldAutorotate : Bool {
        return false
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
    
    func bindProfile() {
        profilePicture.imageFromUrl(userService.currentUser.profilePictureURL)
        nameLabel.text = userService.currentUser.fullName
        profilePicture.makeCircle()
    }
    

    func goBack(){
        dismiss(animated: true, completion: {})
    }
    
    func makeProfileClickable() {
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(StoryTellerMenuViewController.imageTapped(_:)))
        profilePicture.isUserInteractionEnabled = true
        profilePicture.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func imageTapped(_ img: AnyObject) {
        profileView = ProfileView.fromNib("ProfileView")
        profileView.frame = view.frame
        profileView.delegate = self
        profileView.initializeView(userService.currentUser.id)
        view.addSubview(profileView)
        addXBackButton()
    }
    
    func onLoggedOut() {
        self.performSegue(withIdentifier: "StoryTellerMenuToHome", sender: nil)
    }
    
    
    func addXBackButton() {
        let frame = CGRect(x: view.bounds.width - 45, y: 30, width: 30, height: 30)
        xBackButton = XBackButton(frame: frame)
        xBackButton.addTarget(self, action: #selector(dismissProfile), for: .touchUpInside)
        view.addSubview(xBackButton)
    }
    
    func dismissProfile() {
        profileView.removeFromSuperview()
        xBackButton.removeFromSuperview()
    }
    
}
