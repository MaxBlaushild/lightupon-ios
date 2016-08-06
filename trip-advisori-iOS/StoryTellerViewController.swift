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

protocol StoryTellerViewControllerDelegate {
    func toggleRightPanel()
}

class StoryTellerViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, SocketServiceDelegate {
    private let partyService:PartyService = Injector.sharedInjector.getPartyService()
    private let socketService: SocketService = Injector.sharedInjector.getSocketService()
    private var audioPlayer: AVAudioPlayer!
    
    private var player: AVAudioPlayer!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet var storyBackground: UIView!
    
    var delegate: StoryTellerViewControllerDelegate?
    var numberOfCards: Int = 0
    
    @IBAction func openMenu(sender: AnyObject) {
        delegate!.toggleRightPanel()
    }
    
    var partyState: PartyState!
    var currentParty: Party!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        socketService.delegate = self
        
        configureCollectionView()
        styleCollectionView()
        loadBackgroundPicture()
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
    

    func playSound(scene: Scene) {
        print(scene.soundResource)
        let urlstring = scene.soundResource
        let url = NSURL(string: urlstring!)
        print("the url = \(url!)")
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
        print("playing \(url)")
        do {
            self.player = try AVAudioPlayer(contentsOfURL: url)
            player.prepareToPlay()
            player.volume = 1.0
            player.play()
        } catch let error as NSError {
            //self.player = nil
            print(error.localizedDescription)
        } catch {
            print("AVAudioPlayer init failed")
        }
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        playSound(partyState.scene!)
        return partyState.scene!.cards!.count
    }
    
    func onResponseRecieved(newPartyState: PartyState) {
        let oldId = partyState.scene?.id
        
        partyState = newPartyState
        if (partyState.nextSceneAvailable!) {
            goToNextScene()
        }
        
        
        if (oldId != newPartyState.scene!.id!) {
            loadBackgroundPicture()
            loadNewScene()
        }
    }
    
    func loadNewScene() {
        collectionView.reloadData()
        loadBackgroundPicture()
    }
    
    func loadBackgroundPicture() {
        let url = NSURL(string: (partyState.scene?.backgroundUrl)!)
        let data = NSData(contentsOfURL: url!)
        let backgroundImage = UIImage(data: data!)!
        let blurredBackgroundImage = backgroundImage.applyBlurWithRadius(
            CGFloat(5),
            tintColor: nil,
            saturationDeltaFactor: 1.0,
            maskImage: nil
        )
        storyBackground.backgroundColor = UIColor(patternImage: blurredBackgroundImage!)
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let card: Card = partyState.scene!.cards![indexPath.row]
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! CardCollectionViewCell
        
        cell.bindCard(card, nextScene: partyState.nextScene!)

        return cell
    }


}
