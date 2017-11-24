//
//  TripListTableViewCell.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 2/7/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//

import UIKit

class FeedSceneCell: UITableViewCell {
    let likeService = Services.shared.getLikeService()
    
    @IBOutlet weak var tripTitle: UILabel!
    @IBOutlet weak var tripImage: UIImageView!
    @IBOutlet weak var profileImage: UIImageView!
    
    var _scene: Scene!
    var delegate: ProfileViewCreator!
    
    func decorateCell(scene: Scene) {
        let borderColor = UIColor(red: CGFloat(153.00)/255, green: CGFloat(153.00)/255, blue: CGFloat(153.00)/255, alpha: 0.5)
        let thickness = CGFloat(1)
        contentView.layer.addBorder(edge: .bottom, color: borderColor, thickness: thickness)
        tripTitle.text = scene.name
        tag = (scene.trip?.id)!
        _scene = scene
        selectionStyle = .none
        makeProfileClickable()
        
        tripTitle.addShadow()
    }
    
    func makeProfileClickable() {
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(createProfileView))
        profileImage.isUserInteractionEnabled = true
        profileImage.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func createProfileView(sender: AnyObject) {
        delegate.createProfileView(_scene!.trip!.owner!.id)
    }

    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
