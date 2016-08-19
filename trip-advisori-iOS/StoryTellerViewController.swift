//
//  StoryTellerViewController.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 5/19/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//

import UIKit
import AVFoundation
import Alamofire
import MDCSwipeToChoose

private let reuseIdentifier = "cardCollectionViewCell"
private let centerPanelExpandedOffset: CGFloat = 60

protocol MainViewControllerDelegate {
    func toggleRightPanel()
}

class StoryTellerViewController: UIViewController, SocketServiceDelegate, MDCSwipeToChooseDelegate {
    private let partyService = Injector.sharedInjector.getPartyService()
    private let cardService = Injector.sharedInjector.getCardService()
    private var audioPlayer: AVAudioPlayer!
    private var player: AVAudioPlayer!
    private var swipeOptions: MDCSwipeToChooseViewOptions!
    
    var delegate: MainViewControllerDelegate?
    var numberOfCards: Int = 0
    var partyState: PartyState!
    var party: Party!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet var storyBackground: UIView!
    
    @IBAction func openMenu(sender: AnyObject) {
        delegate!.toggleRightPanel()
    }
    
    func getParty() {
        partyService.getUsersParty(self.onPartyRecieved)
    }
    
    func onPartyRecieved(_party_: Party) {
        party = _party_
        bindParty()
    }
    
    func bindParty() {
        titleLabel.text = party.trip!.title
    }
    
    override func viewDidLoad(){
        super.viewDidLoad()
        getParty()
        setSwipeOptions()
    }
    
    func loadSwipeViews() {
        for card in partyState.scene!.cards! {
            loadSwipeView(card)
        }
    }
    
    func loadSwipeView(card: Card) {
        let frame = CGRect(x: 25, y: 120, width: self.view.frame.width - 50, height: self.view.frame.height - 160)
        let swipeView = MDCSwipeToChooseView(frame:frame, options:self.swipeOptions)
        let cardView = loadCardView(card)
        sizeCardView(cardView)
        swipeView.addSubview(cardView)
        self.view.addSubview(swipeView)
    }
    
    func loadCardView(card: Card) -> UIView {
        var cardView:IAmACard = cardService.getView(card.nibId!)
        cardView.card = card
        cardView.nextScene = partyState.nextScene!
        cardView.bindCard()
        return cardView as! UIView
    }
    func sizeCardView(cardView: UIView) {
        cardView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width - 50, height: self.view.frame.height - 160)
    }
    
    func setSwipeOptions()  {
        let options = MDCSwipeToChooseViewOptions()
        options.delegate = self
        options.likedText = nil
        options.likedColor = UIColor.clearColor()
        options.nopeText = nil
        options.nopeColor = UIColor.clearColor()
        options.onPan = { state -> Void in
            if state.thresholdRatio == 1 && state.direction == MDCSwipeDirection.Left {
                print("Photo deleted!")
            }
        }
        self.swipeOptions = options
    }
    
    func viewDidCancelSwipe(view: UIView) -> Void{
        print("Couldn't decide, huh?")
    }
    
    // Sent before a choice is made. Cancel the choice by returning `false`. Otherwise return `true`.
    func view(view:UIView, shouldBeChosenWithDirection:MDCSwipeDirection) -> Bool {
        
        
        return true
    }
    
    // This is called then a user swipes the view fully left or right.
    func view(view: UIView, wasChosenWithDirection: MDCSwipeDirection) -> Void{
        // if no more cards, bring up map view
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
    
    func goToNextScene() {
        partyService.startNextScene(party.id!)
    }
    
    func onPartyLeft() {
        performSegueWithIdentifier("StoryTellerToHome", sender: nil)
    }

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func playSound(scene: Scene) {
        let urlstring = scene.soundResource
        let url = NSURL(string: urlstring!)
        downloadFileFromURL(url!)
    }
    
    func downloadFileFromURL(url:NSURL){
        var downloadTask:NSURLSessionDownloadTask
        downloadTask = NSURLSession.sharedSession().downloadTaskWithURL(url, completionHandler: { (URL, response, error) -> Void in
            self.play(URL!)
            
        })
        downloadTask.resume()
    }
    
    func play(url:NSURL) {
        do {
            self.player = try AVAudioPlayer(contentsOfURL: url)
            player.prepareToPlay()
            player.volume = 1.0
            player.play()
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        playSound(partyState.scene!)
        return partyState.scene!.cards!.count
    }
    
    func onResponseReceived(newPartyState: PartyState) {
        if (partyState == nil) {
            initStoryTeller(newPartyState)
        } else if (newPartyState.nextSceneAvailable!) {
            goToNextScene()
        } else if (hasMovedToNextScene(newPartyState)) {
            loadNewScene(newPartyState)
        }
    }
    
    func hasMovedToNextScene(newPartyState: PartyState) -> Bool {
        return (partyState.scene!.id! != newPartyState.scene!.id!)
    }
    
    func initStoryTeller(newPartyState: PartyState) {
        partyState = newPartyState
        loadSwipeViews()
        loadBackgroundPicture()
    }
    
    func loadNewScene(newPartyState: PartyState) {
        partyState = newPartyState
        loadSwipeViews()
        loadBackgroundPicture()
    }
    
    func loadBackgroundPicture() {
        let backgroundImage = getBackgroundPicture()
        let blurredBackgroundImage = blurBackgroundImage(backgroundImage)
        storyBackground.backgroundColor = UIColor(patternImage: blurredBackgroundImage)
    }
    
    func getBackgroundPicture() -> UIImage {
        let url = NSURL(string: (partyState.scene?.backgroundUrl)!)
        let data = NSData(contentsOfURL: url!)
        return UIImage(data: data!)!
    }
    
    func blurBackgroundImage(backgroundImage: UIImage) -> UIImage {
        return backgroundImage.applyBlurWithRadius(
            CGFloat(5),
            tintColor: nil,
            saturationDeltaFactor: 1.0,
            maskImage: nil
        )!
    }
}
