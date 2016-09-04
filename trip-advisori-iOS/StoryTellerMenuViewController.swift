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
    
    var partyState: PartyState!
    var currentParty: Party!
    
    override func viewDidLoad() {
        leavePartyButton.hidden = true
        super.viewDidLoad()
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
    
    func onResponseReceived(_partyState_: PartyState) {
        partyState = _partyState_
        bindParty()
        configurePartyCollectionView()
    }
    
    func bindParty() {
//        tripTitle.text = partyState.party!.trip!.title
//        passcode.text = partyState.party!.passcode
    }
    
    func bindPartyState(_partyState_: PartyState) {
        partyState = _partyState_
        configurePartyCollectionView()
    }
    
    func configurePartyCollectionView() {
        partyMemberCollectionView.dataSource = self
        partyMemberCollectionView.delegate = self
        partyMemberCollectionView.reloadData()
    }
    
    func removeUserFromPartyList() {
        for (index, partyMember) in partyState.users!.enumerate() {
            if partyMember.email == profileService.profile.email {
                partyState.users?.removeAtIndex(index)
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
        return partyState.users!.count
    }
    
    func loadNewScene() {
//        collectionView.reloadData()
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let user: User = partyState.users![indexPath.row]
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! PartyMemberCollectionViewCell
        
        cell.bindCell(user)
        
        return cell
    }
}
