//
//  BeltOverlayView.swift
//  Lightupon
//
//  Created by Blaushild, Max on 2/4/17.
//  Copyright © 2017 Blaushild, Max. All rights reserved.
//

import UIKit

class BeltConfig {
    var sceneName: String
    var address: String
    var profilePictureUrl: String
    var createdAt: String
    
    init(scene: Scene, card: Card, owner: User) {
        sceneName = scene.name
        address = "\(scene.streetNumber) \(scene.route)"
        profilePictureUrl = owner.profilePictureURL
        createdAt = card.prettyTimeSinceCreation()
    }
}

@objc protocol BeltOverlayDelegate {
    @objc func createProfileView(sender: AnyObject)
}

class BeltOverlayView: UIView {
    
    let xibName = "BeltOverlayView"

    @IBOutlet weak var profileImageViw: UIImageView!
    @IBOutlet weak var sceneNameLabel: UILabel!

    @IBOutlet weak var sceneAddressLabel: UILabel!
    @IBOutlet weak var createdAtLabel: UILabel!
    
    var delegate: BeltOverlayDelegate?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
//        isHidden = true
    }
//    
    
    var config: BeltConfig! {
        willSet {
            sceneNameLabel.text = newValue.sceneName
            sceneAddressLabel.text = newValue.address
            createdAtLabel.text = newValue.createdAt
            
            profileImageViw.imageFromUrl(newValue.profilePictureUrl, success: { img in
                self.profileImageViw.image = img
                self.profileImageViw.makeCircle()
                self.makeProfileClickable()
                self.isHidden = false
            })
        }
    }
    
    func makeProfileClickable() {
        if let delegate = self.delegate {
            let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(delegate.createProfileView))
            profileImageViw.isUserInteractionEnabled = true
            profileImageViw.addGestureRecognizer(tapGestureRecognizer)
        }
    }
}
