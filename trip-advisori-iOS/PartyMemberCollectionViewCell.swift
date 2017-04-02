//
//  PartyMemberCollectionViewCell.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 7/31/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//

import UIKit

class PartyMemberCollectionViewCell: UICollectionViewCell {
    let facebookService: FacebookService = Services.shared.getFacebookService()
    
    @IBOutlet weak var partyMemberProfilePicture: UIImageView!
    @IBOutlet weak var partyMemberFullName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func bindCell(_ partyMember: User) {
        facebookService.getProfile(partyMember.facebookId!, callback: self.bindProfileToCell)
    }
    
    func bindUser(user: User) {
        partyMemberFullName.text = user.fullName
    }
    
    func bindProfileToCell(_ profile: FacebookProfile) {
        partyMemberFullName.text = profile.fullName
        partyMemberProfilePicture.imageFromUrl(profile.profilePictureURL!)
        partyMemberProfilePicture.makeCircle()
    }
    
}
