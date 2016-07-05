//
//  StoryTellerViewController.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 5/19/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//

import UIKit

private let reuseIdentifier = "cardCollectionViewCell"

class StoryTellerViewController: UICollectionViewController, SocketServiceDelegate {
    private let partyService:PartyService = Injector.sharedInjector.getPartyService()
    
    var partyState: PartyState!
    var currentParty: Party!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func openAlert(title: String, message: String) {
        
    }
    
    @IBAction func leaveParty(sender: AnyObject) {
        partyService.leaveParty(currentParty.id, callback: self.onPartyLeft)
    }
    
    func onResponseRecieved(_partyState_: PartyState) {
        
    }
    
    func onPartyLeft() {
        performSegueWithIdentifier("StoryTellerToHome", sender: nil)
    }

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return partyState.scene!.cards!.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> CardCollectionViewCell {
        let card: Card = partyState.scene!.cards![indexPath.row]
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! CardCollectionViewCell
        
        cell.bindCard(card)

        return cell
    }


}
