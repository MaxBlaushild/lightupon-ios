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
    private var audioPlayer: AVAudioPlayer!
    private var player: AVAudioPlayer!
    private var swipeOptions: MDCSwipeToChooseViewOptions!
    
    var delegate: MainViewControllerDelegate?
    var numberOfCards: Int = 0
    var partyState: PartyState!
    var party: Party!
    var cardCount: Int = 0
    
    var compassView: CompassView!
    
    @IBOutlet var storyBackground: UIView!
    @IBOutlet weak var menuButton: UIButton!
    
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
//        titleLabel.text = party.trip!.title
    }
    
    override func viewDidLoad(){
        super.viewDidLoad()
        getParty()
        setSwipeOptions()
    }
    
    func loadSwipeViews() {
//        playSound(partyState.scene!)
        for card in partyState.scene!.cards!.reverse() {
            cardCount += 1
            loadCardView(card)
        }
    }
    
    func loadCardView(card: Card) {
        let frame = CGRect(x: 25, y: 80, width: self.view.frame.width - 50, height: self.view.frame.height - 120)
        let cardView = CardView(card: card, options:self.swipeOptions, frame:frame)
        self.view.addSubview(cardView)
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
        cardCount -= 1
        if (cardCount == 0) {
            openCompass()
        }
    }
    
    func openCompass() {
        compassView = CompassView.fromNib("CompassView")
        compassView.pointCompassTowardScene(partyState.nextScene!)
        animateCompassViewIn()
        tuncCompassViewUnderMenuButton()
    }
    
    func animateCompassViewIn() {
        compassView.frame = CGRect(x: 0, y: self.view.frame.height, width: self.view.frame.width, height: self.view.frame.width)
        UIView.animateWithDuration(0.5, animations: {
            self.compassView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        })
    }
    
    func tuncCompassViewUnderMenuButton() {
        self.menuButton.layer.zPosition = 100000
        self.compassView.layer.zPosition = 0
        self.view.insertSubview(compassView, atIndex: 0)
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
    
    func onPartyLeft() {
        performSegueWithIdentifier("StoryTellerToHome", sender: nil)
    }
    
    func playSound(scene: Scene) {
        let urlstring = scene.soundResource
        if urlstring?.characters.count > 0 {
            let url = NSURL(string: urlstring!)
            downloadFileFromURL(url!)
        }

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
    
    func onResponseReceived(newPartyState: PartyState) {
        if (partyState == nil) {
            initStoryTeller(newPartyState)
        } else if (hasMovedToNextScene(newPartyState)) {
            if (newPartyState.scene!.id! != 0) {
                loadNewScene(newPartyState)
            } else {
                // do trip endy stuff
                // oh ok awesome the read and write pump are dying so it's never getting here
            }
            
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
        removeCompass()
        partyState = newPartyState
        loadSwipeViews()
        loadBackgroundPicture()
    }
    
    func removeCompass() {
        for subview in self.view.subviews {
            if let mapHero = subview as? CompassView {
                mapHero.removeFromSuperview()
            }
        }
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
}
