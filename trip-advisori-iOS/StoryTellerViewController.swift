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

private let reuseIdentifier = "cardCollectionViewCell"
private let centerPanelExpandedOffset: CGFloat = 60

protocol MainViewControllerDelegate {
    func toggleRightPanel()
}

class StoryTellerViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, SocketServiceDelegate {
    private let partyService:PartyService = Injector.sharedInjector.getPartyService()
    private var audioPlayer: AVAudioPlayer!
    private var player: AVAudioPlayer!
    
    var delegate: MainViewControllerDelegate?
    var numberOfCards: Int = 0
    var partyState: PartyState!
    var party: Party!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet var storyBackground: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getParty()
    }
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
    
    func configureCollectionView() {
//        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
//        layout.scrollDirection = UICollectionViewScrollDirection.Horizontal
//        layout.itemSize = CGSize(width: collectionView.frame.width, height: collectionView.frame.width)
//        self.collectionView.collectionViewLayout = layout
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
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
        configureCollectionView()
        loadBackgroundPicture()
    }
    
    func loadNewScene(newPartyState: PartyState) {
        partyState = newPartyState
        collectionView.reloadData()
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

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let card: Card = partyState.scene!.cards![indexPath.row]
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! CardCollectionViewCell
        cell.bindCard(card, nextScene: partyState.nextScene!)
        return cell
    }
}
