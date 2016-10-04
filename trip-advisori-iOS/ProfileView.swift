//
//  ProfileView.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 9/25/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//

import UIKit

protocol ProfileViewDelegate {
    func onLoggedOut() -> Void
}

enum ProfileContext {
    case isUser, following, notFollowing, pending
}

class ProfileView: UIView {
    fileprivate let profileService = Injector.sharedInjector.getProfileService()
    fileprivate let authService = Injector.sharedInjector.getAuthService()

    @IBOutlet weak var actionPackedButton: UIButton!
    @IBOutlet weak var blurImage: UIImageView!
    @IBOutlet weak var circleImage: UIImageView!
    @IBOutlet weak var fullnameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var buttonView: UIView!
    @IBOutlet weak var followerSection: UIView!
    
    fileprivate var profileContext: ProfileContext = ProfileContext.isUser
    fileprivate var actionPackButtonHandler:(() -> Void)!
    
    internal var delegate: ProfileViewDelegate!
    
    @IBAction func onActionPackedButtonPress(_ sender: AnyObject) {
        actionPackButtonHandler()
    }
    
    internal func initializeView(_ facebookId: String) {
        profileService.getProfile(facebookId, callback: self.setProfile)
    }
    
    @nonobjc func initializeView(_ profile: FacebookProfile) {
        setProfile(profile)
    }
    
    func setProfile(_ profile: FacebookProfile) {
        setProfileContext(profile)
        bindProfile(profile)
        style()
    }
    
    func bindProfile(_ profile: FacebookProfile) {
        circleImage.imageFromUrl(profile.profilePictureURL!)
        blurImage.imageFromUrl(profile.profilePictureURL!)
        fullnameLabel.text = profile.fullName
    }
    
    
    func setProfileContext(_ profile: FacebookProfile) {
        let isUser = profileService.isUser(profile)
        profileContext = isUser ? .isUser : .notFollowing
        changeProfileContext()
    }
    
    func changeProfileContext() {
        switch profileContext {
        case .isUser:
            setIsUserState()
        case .following:
            setFollowingState()
        case .notFollowing:
            setNotFollowingState()
        case .pending:
            setPendingState()
        }
    }
    
    func setPendingState() {
        actionPackButtonHandler = {}
        actionPackedButton.setTitle("PENDING", for: UIControlState())
    }
    
    func setIsUserState() {
        actionPackButtonHandler = logout
        actionPackedButton.setTitle("LOGOUT", for: UIControlState())
    }
    
    func setFollowingState() {
        actionPackButtonHandler = unfollow
        actionPackedButton.setTitle("UNFOLLOW", for: UIControlState())
    }
    
    func setNotFollowingState() {
        actionPackButtonHandler = follow
        actionPackedButton.setTitle("FOLLOW", for: UIControlState())
    }
    
    
    func logout() {
        authService.logout()
        delegate.onLoggedOut()
    }
    
    func follow() {
        
    }
    
    func unfollow() {
        
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
        blurView.frame = CGRect(x:0,y:0,width:frame.width,height:frame.height/2)
        addSubview(blurView)
        bringSubview(toFront: circleImage)
        bringSubview(toFront: fullnameLabel)
        bringSubview(toFront: locationLabel)
        bringSubview(toFront: followerSection)
        bringSubview(toFront: buttonView)
    }
}
