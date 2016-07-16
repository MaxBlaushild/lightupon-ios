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
    private let socketService: SocketService = Injector.sharedInjector.getSocketService()
    private let nextSceneButton: UIButton = UIButton()
    
    var partyState: PartyState!
    var currentParty: Party!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let backgroundView = UIView()
        backgroundView.backgroundColor = Colors.basePurple
        self.collectionView!.backgroundView = backgroundView;
        addMenuButton()
        addNextSceneButton()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func openAlert(title: String, message: String) {
        
    }
    
    func addMenuButton() {
        let button   = UIButton()
        button.frame = CGRectMake(250, 25, 100, 50)
        button.backgroundColor = UIColor.whiteColor()
        button.setTitle("Menu", forState: UIControlState.Normal)
        button.setTitleColor(Colors.basePurple, forState: UIControlState.Normal)
        button.addTarget(self, action: #selector(segueToStoryTellerMenu), forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(button)
    }
    
    func addNextSceneButton() {
        nextSceneButton.frame = CGRectMake(150, 590, 100, 50)
        nextSceneButton.backgroundColor = UIColor.whiteColor()
        nextSceneButton.setTitle("NextScene", forState: UIControlState.Normal)
        nextSceneButton.setTitleColor(Colors.basePurple, forState: UIControlState.Normal)
        nextSceneButton.setTitleColor(UIColor.grayColor(), forState: UIControlState.Disabled)
        nextSceneButton.addTarget(self, action: #selector(goToNextScene), forControlEvents: UIControlEvents.TouchUpInside)
        nextSceneButton.enabled = false
        self.view.addSubview(nextSceneButton)
    }
    
    func segueToStoryTellerMenu() {
        performSegueWithIdentifier("StoryTellerToStoryTellerMenu", sender: nil)
    }
    
    func goToNextScene() {
        partyService.startNextScene(currentParty.id)
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
    
    func onResponseRecieved(_partyState_: PartyState) {
        partyState = _partyState_
        nextSceneButton.enabled = partyState.nextSceneAvailable!
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> CardCollectionViewCell {
        let card: Card = partyState.scene!.cards![indexPath.row]
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! CardCollectionViewCell
        
        cell.bindCard(card, nextScene: partyState.nextScene!)

        return cell
    }


}
