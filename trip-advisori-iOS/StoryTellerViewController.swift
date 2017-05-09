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

class StoryTellerViewController: UIViewController, MDCSwipeToChooseDelegate, EndOfTripDelegate, CompassViewDelegate, PartyServiceDelegate {
    private let _partyService = Services.shared.getPartyService()
    
    internal var delegate: MainViewControllerDelegate?
    
    private var _cardCount: Int = 0
    private var _swipeOptions = CardSwipeOptions()
    private var _cardSize: CGRect!
    private var _player: AVAudioPlayer!
    private var _currentSceneId: Int!
    
    
    var compassView: CompassView!
    var endOfTripView: EndOfTripView!
    var nextSceneButton: UIButton!
    
    @IBOutlet var storyBackground: UIView!
    @IBOutlet weak var menuButton: UIButton!
    
    override func viewDidLoad(){
        super.viewDidLoad()
//        
//        _swipeOptions.delegate = self
//        _partyService.registerDelegate(self)
//        
//        createCardSize()
    }
    
    func createCardSize() {
        _cardSize = CGRect(x: 25, y: 80, width: self.view.frame.width - 50, height: self.view.frame.height - 120)
    }
    
    func initalize() {
        if let currentScene = _partyService.currentScene() {
            openCompass(currentScene)
        }
    }
    
    
    func loadScene() {
        _currentSceneId = _partyService.currentScene()?.id
        loadSwipeViews()
        loadBackgroundPicture()
    }
    
    func openCards() {
        loadScene()
    }
    
    func onNextScene(_ scene: Scene) {
        openCompass(scene)
    }

    func onWentToNextScene() {
        loadScene()
    }
    
    func removeCompass() {
        compassView.removeFromSuperview()
        compassView = nil
    }
    
    func outOfCards() -> Bool {
        return (_cardCount == 0)
    }
    
    func handleNoMoreCards() {
        if (_partyService.endOfTrip()) {
            openEndOfTripView()
        } else {
            _partyService.startNextScene()
        }
    }
    
    @IBAction func openMenu(_ sender: AnyObject) {
        delegate!.toggleRightPanel()
    }
    
    func loadSwipeViews() {
        if let currentScene = _partyService.currentScene() {
            for card in currentScene.cards.reversed() {
                _cardCount += 1
                loadCardView(card)
            }
        }
 
    }
    
    func loadCardView(_ card: Card) {
//        let cardView = CardView(card: card, options:_swipeOptions, frame: _cardSize)
//        self.view.addSubview(cardView)
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
    
    
    func loadBackgroundPicture() {
        if let currentScene = _partyService.currentScene() {
            let backgroundImage = getBackgroundPicture(currentScene)
            let blurredBackgroundImage = blurBackgroundImage(backgroundImage)
            storyBackground.backgroundColor = UIColor(patternImage: blurredBackgroundImage)
        }

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
