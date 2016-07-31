//
//  StoryTellerViewController.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 5/19/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//

import UIKit

private let reuseIdentifier = "cardCollectionViewCell"
private let centerPanelExpandedOffset: CGFloat = 60

protocol StoryTellerViewControllerDelegate {
    func toggleRightPanel()
}

class StoryTellerViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, SocketServiceDelegate {
    private let partyService:PartyService = Injector.sharedInjector.getPartyService()
    private let socketService: SocketService = Injector.sharedInjector.getSocketService()
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var delegate: StoryTellerViewControllerDelegate?
    var numberOfCards: Int = 0
    
    @IBAction func openMenu(sender: AnyObject) {
        delegate!.toggleRightPanel()
    }
    
    var partyState: PartyState!
    var currentParty: Party!
    
    @IBOutlet weak var nextSceneButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        socketService.delegate = self

        nextSceneButton.enabled = false
        
        configureCollectionView()
        styleCollectionView()
    }
    
    func configureCollectionView() {
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
    }
    
    func styleCollectionView() {
        let backgroundView = UIView()
        backgroundView.backgroundColor = Colors.basePurple
        collectionView.backgroundView = backgroundView;
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
    
    func openAlert(title: String, message: String) {
        
    }
    
    @IBAction func nextSceneButtonPress(sender: AnyObject) {
        goToNextScene()
    }
    
    func goToNextScene() {
        partyService.startNextScene(currentParty.id)
    }
    
    func onPartyLeft() {
        performSegueWithIdentifier("StoryTellerToHome", sender: nil)
    }

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return partyState.scene!.cards!.count
    }
    
    func onResponseRecieved(newPartyState: PartyState) {
        let oldId = partyState.scene?.id
        
        partyState = newPartyState
        nextSceneButton.enabled = partyState.nextSceneAvailable!
        
        if (oldId != newPartyState.scene!.id!) {
            loadNewScene()
        }
    }
    
    func loadNewScene() {
        collectionView.reloadData()
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let card: Card = partyState.scene!.cards![indexPath.row]
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! CardCollectionViewCell
        
        cell.bindCard(card, nextScene: partyState.nextScene!)

        return cell
    }


}
