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

class StoryTellerViewController: UIViewController, SocketServiceDelegate, MDCSwipeToChooseDelegate, EndOfTripDelegate, CompassViewDelegate {
    private let _partyService = Injector.sharedInjector.getPartyService()
    private let _socketService = Injector.sharedInjector.getSocketService()
    
    internal var delegate: MainViewControllerDelegate?
    
    private var _currentScene: Scene!
    private var _partyState: PartyState!
    private var _party: Party!
    private var _cardCount: Int = 0
    private var _swipeOptions = CardSwipeOptions()
    private var _cardSize: CGRect!
    private var _player: AVAudioPlayer!
    
    var compassView: CompassView!
    var endOfTripView: EndOfTripView!
    var nextSceneButton: UIButton!
    
    @IBOutlet var storyBackground: UIView!
    @IBOutlet weak var menuButton: UIButton!
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        _swipeOptions.delegate = self
        _socketService.registerDelegate(self)
        
        createCardSize()
    }
    
    func createCardSize() {
        _cardSize = CGRect(x: 25, y: 80, width: self.view.frame.width - 50, height: self.view.frame.height - 120)
    }
    
    func bindParty(party: Party) {
        setParty(party)
        setScene()
        
        if (_currentScene.id != nil) {
            loadScene()
        } else {
            openCompass(_party.trip!.getSceneWithOrder(1))
        }

    }
    
    func loadNextScene() {
        goToNextSceneInMemory()
        loadScene()
    }
    
    func setScene() {
        _currentScene = _party.trip?.getSceneWithOrder(_party.currentSceneOrder!)
    }
    
    func loadScene() {
        loadSwipeViews()
        loadBackgroundPicture()
    }
    
    func goToNextSceneInMemory() {
        _currentScene = getNextScene()
    }
    
    func getNextScene() -> Scene {
        if (_currentScene.id != nil) {
            let nextSceneOrder = _currentScene.sceneOrder! + 1
            return _party.trip!.getSceneWithOrder(nextSceneOrder)
        } else {
            return _party.trip!.getSceneWithOrder(1)
        }
    }
    
    func setParty(party: Party) {
        _party = party
    }
    
    func onResponseReceived(partyState: PartyState) {
        _partyState = partyState
    }
    
    func goToNextScene() {
        _partyService.startNextScene(_party.id!, callback: {})
        onWentToNextScene()
    }
    
    func onWentToNextScene() {
        removeCompass()
        loadNextScene()
    }
    
    func removeCompass() {
        compassView.removeFromSuperview()
        compassView = nil
    }
    
    func outOfCards() -> Bool {
        return (_cardCount == 0)
    }
    
    func handleNoMoreCards() {
        if (endOfTrip()) {
            openEndOfTripView()
        } else {
            openCompass(getNextScene())
        }
    }
    
    @IBAction func openMenu(sender: AnyObject) {
        delegate!.toggleRightPanel()
    }
    
    func loadSwipeViews() {
        for card in _currentScene.cards!.reverse() {
            _cardCount += 1
            loadCardView(card)
        }
    }
    
    func loadCardView(card: Card) {
        let cardView = CardView(card: card, options:_swipeOptions, frame: _cardSize)
        self.view.addSubview(cardView)
    }
    
    func viewDidCancelSwipe(view: UIView) -> Void {}
    
    func view(view:UIView, shouldBeChosenWithDirection:MDCSwipeDirection) -> Bool {
        return true
    }
    
    func view(view: UIView, wasChosenWithDirection: MDCSwipeDirection) -> Void{
        _cardCount -= 1
        
        if (outOfCards()) {
            handleNoMoreCards()
        }
    }
    
    func endOfTrip() -> Bool {
        let nextScene = getNextScene()
        return (nextScene.id == nil)
    }
    
    func onTripEnds() {
        performSegueWithIdentifier("StoryTellerToInitial", sender: nil)
    }
    
    func openEndOfTripView() {
        endOfTripView = EndOfTripView.fromNib("EndOfTripView")
        endOfTripView.frame = _cardSize
        endOfTripView.delegate = self
        self.view.addSubview(endOfTripView)
    }
    
    func openCompass(nextScene: Scene) {
        compassView = CompassView.fromNib("CompassView")
        compassView.delegate = self
        compassView.pointCompassTowardScene(nextScene)
        compassView.frame = self.view.frame
        tuckCompassViewUnderMenuButton()
    }
    
    func tuckCompassViewUnderMenuButton() {
        self.menuButton.layer.zPosition = 100000
        self.compassView.layer.zPosition = 0
        self.view.insertSubview(compassView, atIndex: 0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
            _player = try AVAudioPlayer(contentsOfURL: url)
            _player.prepareToPlay()
            _player.volume = 1.0
            _player.play()
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    func loadBackgroundPicture() {
        let backgroundImage = getBackgroundPicture(_currentScene)
        let blurredBackgroundImage = blurBackgroundImage(backgroundImage)
        storyBackground.backgroundColor = UIColor(patternImage: blurredBackgroundImage)
    }
    
    func getBackgroundPicture(scene: Scene) -> UIImage {
        let url = NSURL(string: (scene.backgroundUrl)!)
        let data = NSData(contentsOfURL: url!)
        return UIImage(data: data!)!
    }
    
    func blurBackgroundImage(backgroundImage: UIImage) -> UIImage {
        return backgroundImage.applyBlurWithRadius(CGFloat(5), tintColor: nil, saturationDeltaFactor: 1.0, maskImage: nil)!
    }
}
