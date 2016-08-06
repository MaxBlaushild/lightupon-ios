//
//  StoryTellerViewController.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 5/19/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//

import UIKit
import AVFoundation

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
