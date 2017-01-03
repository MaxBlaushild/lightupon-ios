//
//  TripDetailsView.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 9/11/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//

import UIKit

protocol TripDetailsViewDelegate {
    func segueToContainer() -> Void
}

class DefaultCardDetailsView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    fileprivate let tripsService: TripsService = Injector.sharedInjector.getTripsService()
    fileprivate let partyService: PartyService = Injector.sharedInjector.getPartyService()
    fileprivate let commentService: CommentService = Injector.sharedInjector.getCommentService()
    
    fileprivate var _tripId: Int!
    fileprivate var _owner: User!
    fileprivate var _comments: [Comment] = [Comment]()
    
    internal var delegate: TripDetailsViewDelegate!
    
    @IBOutlet weak var cardImageView: UIImageView!
    @IBOutlet weak var ownerImageView: UIImageView!
    @IBOutlet weak var ownerName: UILabel!
    @IBOutlet weak var cardText: UILabel!
    @IBOutlet weak var cardTimestamp: UILabel!
    @IBOutlet weak var commentCollectionView: UICollectionView!
    
    func initFrom(card: Card, owner: User, scene: Scene) {
        configureCommentCollectionView()
        getCommentsForCard(card)
        bindOwner(owner)
        bindCard(card)
    }
    
    func bindCard(_ card: Card) {
        cardImageView.imageFromUrl(card.imageUrl!)
        cardTimestamp.text = card.prettyTimeSinceCreation()
        cardText.text = "Where does this come from?"
    }
    
    func bindOwner(_ owner: User) {
        ownerName.text = owner.fullName
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
    
    @IBAction func createParty(_ sender: UIButton) {
        sender.isEnabled = false
        partyService.createParty(_tripId!, callback: self.onPartyCreated)
        
    }
    
    func onPartyCreated() {
        delegate.segueToContainer()
    }
    
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
