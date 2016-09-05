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

class StoryTellerViewController: UIViewController, SocketServiceDelegate, MDCSwipeToChooseDelegate, EndOfTripDelegate {
    private let partyService = Injector.sharedInjector.getPartyService()
    private let socketService = Injector.sharedInjector.getSocketService()
    
    private var audioPlayer: AVAudioPlayer!
    private var player: AVAudioPlayer!
    private var swipeOptions: MDCSwipeToChooseViewOptions!
    
    var delegate: MainViewControllerDelegate?
    var numberOfCards: Int = 0
    var partyState: PartyState!
    var _party: Party!
    var cardCount: Int = 0
    
    var compassView: CompassView!
    var endOfTripView: EndOfTripView!
    
    @IBOutlet var storyBackground: UIView!
    @IBOutlet weak var menuButton: UIButton!
    
    override func viewDidLoad(){
        super.viewDidLoad()
        socketService.registerDelegate(self)
        getParty()
        setSwipeOptions()
    }
    
    @IBAction func openMenu(sender: AnyObject) {
        delegate!.toggleRightPanel()
    }
    
    
    func getParty() {
        partyService.getUsersParty(self.onPartyRecieved)
    }
    
    func onPartyRecieved(party: Party) {
        _party = party
        bindParty()
    }
    
    func bindParty() {
//        titleLabel.text = party.trip!.title
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
            if (partyState.nextScene!.id == 0) {
                openEndOfTripView()
            } else {
                openCompass()
            }

        }
    }
    
    func onTripEnds() {
        performSegueWithIdentifier("StoryTellerToInitial", sender: nil)
    }
    
    func openEndOfTripView() {
        endOfTripView = EndOfTripView.fromNib("EndOfTripView")
        endOfTripView.frame = CGRect(x: 25, y: 80, width: self.view.frame.width - 50, height: self.view.frame.height - 120)
        endOfTripView.delegate = self
        self.view.addSubview(endOfTripView)
    }
    
    func openCompass() {
        compassView = CompassView.fromNib("CompassView")
        compassView.pointCompassTowardScene(partyState.nextScene!)
        compassView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        tuncCompassViewUnderMenuButton()
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
                removeCompass()
                openEndOfTripView()
            }
        } else if (newPartyState.nextSceneAvailable!) {
            addNextSceneButton()
        }
    }
    
    func goToNextScene() {
        partyService.startNextScene(_party.id!)
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
    
    func addNextSceneButton() {
        let nextSceneButton = UIButton(type: .Custom)
        nextSceneButton.frame = CGRectMake(view.frame.width / 2, view.frame.height * 0.7 + 30, 0, 0)

        nextSceneButton.addTarget(self, action: #selector(goToNextScene), forControlEvents: .TouchUpInside)
        view.addSubview(nextSceneButton)
        animateInNextSceneButton(nextSceneButton)
    }
    
    func animateInNextSceneButton(nextSceneButton: UIButton) {
        UIView.animateWithDuration(0.5, animations: {
            nextSceneButton.frame = CGRectMake(self.view.frame.width / 2 - 30, self.view.frame.height * 0.7, 60, 60)
            nextSceneButton.layer.cornerRadius = 0.5 * nextSceneButton.bounds.size.width
            nextSceneButton.backgroundColor = UIColor.whiteColor()
            nextSceneButton.layer.borderColor = UIColor.blackColor().CGColor
            nextSceneButton.layer.borderWidth = 2
            nextSceneButton.clipsToBounds = true
        })
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
