//
//  ProfileView.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 9/25/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//

import UIKit

class ProfileView: UIView {
    private let profileService = Injector.sharedInjector.getProfileService()

    @IBOutlet weak var actionPackedButton: UIButton!
    @IBOutlet weak var blurImage: UIImageView!
    @IBOutlet weak var circleImage: UIImageView!
    @IBOutlet weak var fullnameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    
    @IBOutlet weak var buttonView: UIView!
    @IBOutlet weak var followerSection: UIView!
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
    
    internal func initializeView(facebookId: String) {
        profileService.getProfile(facebookId, callback: self.bindProfile)
    }
    
    @nonobjc func initializeView(profile: FacebookProfile) {
        bindProfile(profile)
    }
    
    func bindProfile(profile: FacebookProfile) {
        circleImage.imageFromUrl(profile.profilePictureURL!)
        blurImage.imageFromUrl(profile.profilePictureURL!)
        fullnameLabel.text = profile.fullName
        style()
        
    }
    
    func blur() {
        
    }
}
