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
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var daysSince: UILabel!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    
    var _scene: Scene!
    var delegate: ProfileViewCreator!
    
    func decorateCell(scene: Scene) {
        let borderColor = UIColor(red: CGFloat(153.00)/255, green: CGFloat(153.00)/255, blue: CGFloat(153.00)/255, alpha: 0.5)
        let thickness = CGFloat(1)
        contentView.layer.addBorder(edge: .bottom, color: borderColor, thickness: thickness)
        userName.text = scene.trip?.owner?.fullName
        daysSince.text = scene.prettyTimeSinceCreation()
        tripTitle.text = scene.name
        location.text = "\(scene.neighborhood)"
        tag = (scene.trip?.id!)!
        _scene = scene
        selectionStyle = .none
        setLikeButton()
        makeProfileClickable()
    }
    
    func makeProfileClickable() {
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(createProfileView))
        let secondIdenticalRecognizerForSomeReason = UITapGestureRecognizer(target:self, action:#selector(createProfileView))
        profileImage.isUserInteractionEnabled = true
        profileImage.addGestureRecognizer(tapGestureRecognizer)
        userName.isUserInteractionEnabled = true
        userName.addGestureRecognizer(secondIdenticalRecognizerForSomeReason)
    }
    
    func createProfileView(sender: AnyObject) {
        delegate.createProfileView(user: _scene!.trip!.owner!)
    }
    
    func toggleLikeButton() {
        _scene.liked! = !_scene.liked!
        setLikeButton()
    }
    
    func setLikeButton() {
        likeButton.imageView?.image = _scene.liked! ?  UIImage(named: "liked") : UIImage(named: "like")
    }
    
    
    @IBAction func like(_ sender: Any) {
        _scene.liked! ? likeService.unlikeScene(scene: _scene, success: self.toggleLikeButton) : likeService.likeScene(scene: _scene, success: self.toggleLikeButton)
    }
    
    @IBAction func comment(_ sender: Any) {
        
    }
    
    @IBAction func share(_ sender: Any) {
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
