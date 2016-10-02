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
    private let profileService = Injector.sharedInjector.getProfileService()
    private let authService = Injector.sharedInjector.getAuthService()

    @IBOutlet weak var actionPackedButton: UIButton!
    @IBOutlet weak var blurImage: UIImageView!
    @IBOutlet weak var circleImage: UIImageView!
    @IBOutlet weak var fullnameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var buttonView: UIView!
    @IBOutlet weak var followerSection: UIView!
    
    private var profileContext: ProfileContext = ProfileContext.isUser
    private var actionPackButtonHandler:(() -> Void)!
    
    internal var delegate: ProfileViewDelegate!
    
    @IBAction func onActionPackedButtonPress(sender: AnyObject) {
        actionPackButtonHandler()
    }
    
    internal func initializeView(facebookId: String) {
        profileService.getProfile(facebookId, callback: self.setProfile)
    }
    
    @nonobjc func initializeView(profile: FacebookProfile) {
        setProfile(profile)
    }
    
    func setProfile(profile: FacebookProfile) {
        setProfileContext(profile)
        bindProfile(profile)
        style()
    }
    
    func bindProfile(profile: FacebookProfile) {
        circleImage.imageFromUrl(profile.profilePictureURL!)
        blurImage.imageFromUrl(profile.profilePictureURL!)
        fullnameLabel.text = profile.fullName
    }
    
    
    func setProfileContext(profile: FacebookProfile) {
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
        actionPackedButton.setTitle("PENDING", forState: .Normal)
    }
    
    func setIsUserState() {
        actionPackButtonHandler = logout
        actionPackedButton.setTitle("LOGOUT", forState: .Normal)
    }
    
    func setFollowingState() {
        actionPackButtonHandler = unfollow
        actionPackedButton.setTitle("UNFOLLOW", forState: .Normal)
    }
    
    func setNotFollowingState() {
        actionPackButtonHandler = follow
        actionPackedButton.setTitle("FOLLOW", forState: .Normal)
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
        bringSubviewToFront(circleImage)
        bringSubviewToFront(fullnameLabel)
        bringSubviewToFront(locationLabel)
        bringSubviewToFront(followerSection)
        bringSubviewToFront(buttonView)
    }
}
