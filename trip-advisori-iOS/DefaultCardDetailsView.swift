//
//  TripDetailsView.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 9/11/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//

import UIKit

class DefaultCardDetailsView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    fileprivate let tripsService: TripsService = Services.shared.getTripsService()
    fileprivate let partyService: PartyService = Services.shared.getPartyService()
    fileprivate let commentService: CommentService = Services.shared.getCommentService()
    
    fileprivate var _tripId: Int!
    fileprivate var _owner: User!
    fileprivate var _comments: [Comment] = [Comment]()
    
    internal var delegate: ProfileViewCreator!
    
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var beltOverlay: UIView!
    @IBOutlet weak var cardImageView: UIImageView!
    @IBOutlet weak var ownerImageView: UIImageView!
    @IBOutlet weak var sceneName: UILabel!
    @IBOutlet weak var cardText: UILabel!
    @IBOutlet weak var cardTimestamp: UILabel!
    @IBOutlet weak var commentCollectionView: UICollectionView!
    @IBOutlet weak var checkItOutButton: UIButton!
    
    func initFrom(card: Card, owner: User, scene: Scene) {
        configureCommentCollectionView()
        getCommentsForCard(card)
        bindOwner(owner)
        bindCard(card)
        bindScene(scene)
        makeProfileClickable()
        
        checkItOutButton.backgroundColor = UIColor.basePurple
    }

    @IBAction func goOnTrip(_ sender: UIButton) {
        sender.isEnabled = false
        partyService.createParty(_tripId!, callback: self.onPartyCreated)
    }
    
    func onPartyCreated() {
        if let cardViewController = delegate as? CardViewController {
            cardViewController.onPartyCreated()
        }
    }
    
    func makeProfileClickable() {
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(createProfileView))
        ownerImageView.isUserInteractionEnabled = true
        ownerImageView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func createProfileView(sender: AnyObject) {
        delegate.createProfileView(user: _owner)
    }
    
    func setBottomViewHeight(newHeight: CGFloat) {
        bottomView.frame.origin.y = newHeight
    }
    
    func slideBeltOverlay(newHeight: CGFloat) {
        UIView.animate(withDuration: 0.5, animations: {
            self.beltOverlay.frame.origin.y = newHeight
        })
    }
    
    func bindCard(_ card: Card) {
        cardImageView.imageFromUrl(card.imageUrl!)
        cardTimestamp.text = card.prettyTimeSinceCreation()
        cardText.text = "Caption of the card"
    }
    
    func bindScene(_ scene: Scene) {
        sceneName.text = "Name of the scene"
        _tripId = scene.tripId
    }
    
    func bindOwner(_ owner: User) {
        _owner = owner
        
        ownerImageView.imageFromUrl((owner.profilePictureURL)!, success: { img in
            self.ownerImageView.image = img
            self.ownerImageView.makeCircle()
        })
    }
    
    func configureCommentCollectionView() {
        commentCollectionView.dataSource = self
        commentCollectionView.delegate = self
        let nibName = UINib(nibName: "CommentCollectionViewCell", bundle:nil)
        commentCollectionView.register(nibName, forCellWithReuseIdentifier: "CommentCollectionViewCell")
        commentCollectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: commentCollectionView.bounds.size.width, height: 40);
    }
    
    func getCommentsForCard(_ card: Card) {
        commentService.getCommentsFor(card: card, success: self.onCommentsReceived)
    }
    
    func onCommentsReceived(comments: [Comment]) {
        _comments = comments
        commentCollectionView.reloadData()
    }
    
//    @IBAction func createParty(_ sender: UIButton) {
//        sender.isEnabled = false
//        partyService.createParty(_tripId!, callback: self.onPartyCreated)
//        
//    }
    
    func shouldAutorotate() -> Bool {
        return false
    }
    
    func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return _comments.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let comment = _comments[(indexPath as NSIndexPath).row]
        let cell = commentCollectionView.dequeueReusableCell(withReuseIdentifier: "CommentCollectionViewCell", for: indexPath) as! CommentCollectionViewCell
        
        cell.profilePictureView.imageFromUrl((comment.owner?.profilePictureURL!)!, success: { img in
            cell.profilePictureView.image = img
            cell.profilePictureView.makeCircle()
        })
        
        cell.setComment(comment: comment)
        
        return cell
    }


}
