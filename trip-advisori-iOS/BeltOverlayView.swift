//
//  BeltOverlayView.swift
//  Lightupon
//
//  Created by Blaushild, Max on 2/4/17.
//  Copyright © 2017 Blaushild, Max. All rights reserved.
//

import UIKit

class BeltOverlayView: UIView {

    @IBOutlet weak var profileImageViw: UIImageView!
    @IBOutlet weak var sceneNameLabel: UILabel!
    @IBOutlet weak var cardCaptionLabel: UILabel!
    @IBOutlet weak var createdAtLabel: UILabel!
    
    func bindView(scene: Scene, owner: User, card: Card) {
        sceneNameLabel.text = scene.name
        cardCaptionLabel.text = card.caption
        createdAtLabel.text = card.prettyTimeSinceCreation()
        
        profileImageViw.imageFromUrl(owner.profilePictureURL!, success: { img in
            self.profileImageViw.image = img
            self.profileImageViw.makeCircle()
        })
    }

}
