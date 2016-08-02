//
//  StoryTellerMenuViewController.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 7/5/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//

import UIKit


private let reuseIdentifier = "PartyMemberCollectionViewCell"

class StoryTellerMenuViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    let partyService: PartyService = Injector.sharedInjector.getPartyService()
    let profileService: ProfileService = Injector.sharedInjector.getProfileService()

    @IBOutlet weak var partyMemberCollectionView: UICollectionView!
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var tripTitle: UILabel!
    @IBOutlet weak var passcode: UILabel!
    
    var partyState: PartyState!
    var currentParty: Party!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindProfile()
        
        partyMemberCollectionView.dataSource = self
        partyMemberCollectionView.delegate = self
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
        profilePicture.makeCircle()
    }
    
    func bindParty(currentParty: Party) {
        tripTitle.text = currentParty.trip.title
        passcode.text = currentParty.passcode
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
