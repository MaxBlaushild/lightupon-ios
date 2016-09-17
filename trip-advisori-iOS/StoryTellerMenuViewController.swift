//
//  StoryTellerMenuViewController.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 7/5/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//

import UIKit


private let reuseIdentifier = "PartyMemberCollectionViewCell"

class StoryTellerMenuViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, SocketServiceDelegate {
    
    private let partyService: PartyService = Injector.sharedInjector.getPartyService()
    private let profileService: ProfileService = Injector.sharedInjector.getProfileService()
    private let socketService: SocketService = Injector.sharedInjector.getSocketService()

    @IBOutlet weak var partyMemberCollectionView: UICollectionView!
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var leavePartyButton: UIButton!
    
    private var _partyState: PartyState!
    private var _party: Party!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        leavePartyButton.hidden = true
        socketService.registerDelegate(self)
        bindProfile()
        makeProfileClickable()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
    func bindProfile() {
        profilePicture.imageFromUrl(profileService.profile.profilePictureURL!)
        nameLabel.text = profileService.profile.fullName
        profilePicture.makeCircle()
    }
    
    func onResponseReceived(partyState: PartyState) {
        _partyState = partyState
        configurePartyCollectionView()
    }
    
    func bindParty(party: Party) {
        _party = party
        leavePartyButton.hidden = false
    }
    func configurePartyCollectionView() {
        partyMemberCollectionView.dataSource = self
        partyMemberCollectionView.delegate = self
        partyMemberCollectionView.reloadData()
    }
    
    func removeUserFromPartyList() {
        for (index, partyMember) in _partyState.users!.enumerate() {
            if partyMember.email == profileService.profile.email {
                _partyState.users?.removeAtIndex(index)
            }
        }
    }

    func goBack(){
        dismissViewControllerAnimated(true, completion: {})
    }
    
    func makeProfileClickable() {
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(StoryTellerMenuViewController.imageTapped(_:)))
        profilePicture.userInteractionEnabled = true
        profilePicture.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func imageTapped(img: AnyObject) {
        self.performSegueWithIdentifier("MenuToProfile", sender: nil)
    }
    
    @IBAction func leaveParty(sender: AnyObject) {
        partyService.leaveParty({
            self.performSegueWithIdentifier("StoryTellerMenuToHome", sender: nil)
        })
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        removeUserFromPartyList()
        return _partyState.users!.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let user: User = _partyState.users![indexPath.row]
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! PartyMemberCollectionViewCell
        
        cell.bindCell(user)
        
        return cell
    }
}
