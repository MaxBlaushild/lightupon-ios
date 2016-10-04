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
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


private let reuseIdentifier = "cardCollectionViewCell"
private let centerPanelExpandedOffset: CGFloat = 60

protocol MainViewControllerDelegate {
    func toggleRightPanel()
}

class StoryTellerViewController: UIViewController, SocketServiceDelegate, MDCSwipeToChooseDelegate, EndOfTripDelegate, CompassViewDelegate {
    fileprivate let _partyService = Injector.sharedInjector.getPartyService()
    fileprivate let _socketService = Injector.sharedInjector.getSocketService()
    
    internal var delegate: MainViewControllerDelegate?
    
    fileprivate var _currentScene: Scene!
    fileprivate var _partyState: PartyState!
    fileprivate var _party: Party!
    fileprivate var _cardCount: Int = 0
    fileprivate var _swipeOptions = CardSwipeOptions()
    fileprivate var _cardSize: CGRect!
    fileprivate var _player: AVAudioPlayer!
    
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
    
    func bindParty(_ party: Party) {
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
//        loadBackgroundPicture()
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
    
    func setParty(_ party: Party) {
        _party = party
    }
    
    func onResponseReceived(_ partyState: PartyState) {
        _partyState = partyState
    }
    
    func goToNextScene() {
        _partyService.startNextScene(partyID: _party.id!, callback: {})
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
    
    @IBAction func openMenu(_ sender: AnyObject) {
        delegate!.toggleRightPanel()
    }
    
    func loadSwipeViews() {
        for card in _currentScene.cards!.reversed() {
            _cardCount += 1
            loadCardView(card)
        }
    }
    
    func loadCardView(_ card: Card) {
        let cardView = CardView(card: card, options:_swipeOptions, frame: _cardSize)
        self.view.addSubview(cardView)
    }
    
    func viewDidCancelSwipe(_ view: UIView) -> Void {}
    
    func view(_ view:UIView, shouldBeChosenWith shouldBeChosenWithDirection:MDCSwipeDirection) -> Bool {
        return true
    }
    
    func view(_ view: UIView, wasChosenWith wasChosenWithDirection: MDCSwipeDirection) -> Void{
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
        performSegue(withIdentifier: "StoryTellerToInitial", sender: nil)
    }
    
    func openEndOfTripView() {
        endOfTripView = EndOfTripView.fromNib("EndOfTripView")
        endOfTripView.frame = _cardSize
        endOfTripView.delegate = self
        self.view.addSubview(endOfTripView)
    }
    
    func openCompass(_ nextScene: Scene) {
        compassView = CompassView.fromNib("CompassView")
        compassView.delegate = self
        compassView.pointCompassTowardScene(nextScene)
        compassView.frame = self.view.frame
        tuckCompassViewUnderMenuButton()
    }
    
    func tuckCompassViewUnderMenuButton() {
        self.menuButton.layer.zPosition = 100000
        self.compassView.layer.zPosition = 0
        self.view.insertSubview(compassView, at: 0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override var shouldAutorotate : Bool {
        return false
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
    
    func onPartyLeft() {
        performSegue(withIdentifier: "StoryTellerToHome", sender: nil)
    }
    
    func playSound(_ scene: Scene) {
        let urlstring = scene.soundResource
        
        if urlstring?.characters.count > 0 {
            let url = URL(string: urlstring!)
            downloadFileFromURL(url!)
        }

    }
    
    func downloadFileFromURL(_ url:URL){
        var downloadTask:URLSessionDownloadTask
        downloadTask = URLSession.shared.downloadTask(with: url, completionHandler: { (URL, response, error) -> Void in
            self.play(URL!)
            
        })
        downloadTask.resume()
    }
    
    func play(_ url:URL) {
        do {
            _player = try AVAudioPlayer(contentsOf: url)
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
    
    func getBackgroundPicture(_ scene: Scene) -> UIImage {
        let url = URL(string: (scene.backgroundUrl)!)
        let data = try? Data(contentsOf: url!)
        return UIImage(data: data!)!
    }
    
    func blurBackgroundImage(_ backgroundImage: UIImage) -> UIImage {
        return backgroundImage.applyBlurWithRadius(CGFloat(5), tintColor: nil, saturationDeltaFactor: 1.0, maskImage: nil)!
    }
}
