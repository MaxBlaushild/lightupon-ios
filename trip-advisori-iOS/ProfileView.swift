//
//  ProfileView.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 9/25/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//


// ASGARD

import UIKit
import GoogleMaps

protocol ProfileViewDelegate {
    func onLoggedOut() -> Void
}

protocol ProfileViewCreator {
    func createProfileView(_ userId: Int)
}

class ProfileView: UIView  {
    fileprivate let authService = Services.shared.getAuthService()
    fileprivate let userService = Services.shared.getUserService()

    @IBOutlet weak var actionPackedButton: UIButton!
    @IBOutlet weak var blurImage: UIImageView!
    @IBOutlet weak var circleImage: UIImageView!
    @IBOutlet weak var fullnameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var buttonView: UIView!
    @IBOutlet weak var followerSection: UIView!
    @IBOutlet weak var fadedCoolGuyView: UIView!
    
    fileprivate var actionPackButtonHandler:(() -> Void)!
    fileprivate var drawerIsOpen = false
    fileprivate var scrollingUp = false
    fileprivate var drawerHeight: CGFloat = 0.0
    
    fileprivate var _user: User!
    fileprivate var _posts: [Post] = [Post]()
    
    internal var delegate: ProfileViewDelegate!
    
    @IBAction func onActionPackedButtonPress(_ sender: AnyObject) {
        logout()
    }
    
    @nonobjc func initializeView(_ userId: Int) {
        getUser(userId)
        style()
    }
    
    func getUser(_ userID: Int) {
        userService.getUser(userID, success: self.setUser)
    }

    func setUser(_ user: User) {
        _user = user
        setUserContext(user)
        bindUser(user)
    }
    
    func refresh() {
        getUser(_user.id)
    }
    
    func bindUser(_ user: User) {
        circleImage.imageFromUrl(user.profilePictureURL)
        blurImage.imageFromUrl(user.profilePictureURL)
        fullnameLabel.text = user.fullName
    }
    
    func setUserContext(_ user: User) {
        let isUser = userService.isUser(user.profile)
        actionPackedButton.isHidden = !isUser
    }
    
    func logout() {
        authService.logout()
        delegate.onLoggedOut()
    }
    
    func style() {
        styleCircleImage()
        styleBlurImage()
    }
    
    func styleCircleImage() {
        circleImage.makeCircle()
        circleImage.addShadow()
    }
    
    func styleBlurImage() {
        let blurView = BlurView(onClick: {})
        blurView.frame = CGRect(
            x: 0,
            y: 0,
            width: UIScreen.main.bounds.width,
            height: frame.height * 0.5
        )
        fadedCoolGuyView.insertSubview(blurView, aboveSubview: blurImage)
    }
    
    
}
