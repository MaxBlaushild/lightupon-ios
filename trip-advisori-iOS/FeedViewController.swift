//
//  TripListTableViewController.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 2/6/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//

import UIKit

class FeedViewController: TripModalPresentingViewController, UITableViewDelegate, UITableViewDataSource, ProfileViewDelegate, ProfileViewCreator, TripDetailsViewControllerDelegate {
    fileprivate let tripsService = Services.shared.getTripsService()
    fileprivate let currentLocationService = Services.shared.getCurrentLocationService()
    fileprivate let feedService = Services.shared.getFeedService()
    
    var _scenes:[Scene] = [Scene]()
    var delegate: MainViewControllerDelegate!
    
    var profileView: ProfileView!
    var toggleBackView: UIView!
    var xBackButton: XBackButton!
    var refresher: UIRefreshControl!
    var tripDetailsViewController: TripDetailsViewController!
    
    var onViewOpened:((Int) -> Void)!
    var onViewClosed:(() -> Void)!
    
    var page = 0

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var partyButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableView.addSubview(refresher)
        getFeed(callback: nil)
    }
    
    func refresh() {
        page = 0
        getFeed(callback: { scenes in
            self.onFeedGotten(scenes: scenes)
            self.refresher.endRefreshing()
        })
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastRowIndex = tableView.numberOfRows(inSection: 0)
        if indexPath.row == lastRowIndex - 1 {
            getFeed(callback: { scenes in
                self._scenes.append(contentsOf: scenes)
                self.tableView.reloadData()
            })
        }
    }
    
    @IBAction func openPartyMenu(_ sender: Any) {
        delegate.toggleRightPanel()
        toggleBackView = UIView(frame: self.view.frame)
        toggleBackView.backgroundColor = .clear
        view.addSubview(toggleBackView)
        view.bringSubview(toFront: toggleBackView)
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(toggleBack))
        toggleBackView.isUserInteractionEnabled = true
        toggleBackView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func toggleBack() {
        toggleBackView.removeFromSuperview()
        toggleBackView = nil
        delegate.toggleRightPanel()
    }
    
    func canStartParty() -> Bool {
        return tripDetailsViewController != nil
    }
    
    func onDismissed() {
        tripDetailsViewController = nil
        onViewClosed()
    }
    
    func createProfileView(_ userId: Int) {
        profileView = ProfileView.fromNib("ProfileView")
        profileView.frame = view.frame
        profileView.delegate = self
        profileView.initializeView(userId)
        view.addSubview(profileView)
        addXBackButton()
    }
    
    func addXBackButton() {
        let frame = CGRect(x: view.bounds.width - 45, y: 30, width: 30, height: 30)
        xBackButton = XBackButton(frame: frame)
        xBackButton.addTarget(self, action: #selector(dismissProfile), for: .touchUpInside)
        view.addSubview(xBackButton)
    }
    
    func dismissProfile() {
        profileView.removeFromSuperview()
        xBackButton.removeFromSuperview()
    }
    
    func onLoggedOut() {}
    
    func configureTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        tableView.showsVerticalScrollIndicator = false
        let nibName = UINib(nibName: "FeedSceneCell", bundle:nil)
        tableView.register(nibName, forCellReuseIdentifier: "FeedSceneCell")
    }
    
    func getFeed(callback: (([Scene]) -> Void)?) {
        let callback = callback ?? self.onFeedGotten
        feedService.getFeed(page: page, success: callback)
        page += 1
    }
    
    func onFeedGotten(scenes: [Scene]) {
        _scenes = scenes
        tableView.reloadData()
    }
    
    override var shouldAutorotate : Bool {
        return false
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _scenes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:FeedSceneCell = tableView.dequeueReusableCell(withIdentifier: "FeedSceneCell", for: indexPath) as! FeedSceneCell
//        let scene = _scenes[(indexPath as NSIndexPath).row]
//        let pictureUrl = post.owner?.profilePictureURL
//        cell.decorateCell(post: post)
//        cell.profileImage.imageFromUrl(pictureUrl!, success: { img in
//            cell.profileImage.image = img
//            cell.profileImage.makeCircle()
//        })
//        
//        cell.tripImage.imageFromUrl(scene.cards[0].imageUrl)
//        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        let scene: Scene = _scenes[indexPath.row]
        tripDetailsViewController = TripDetailsViewController(scene: scene, blurApplies: false)
        addChildViewController(tripDetailsViewController)
        tripDetailsViewController.view.frame = view.frame
        tripDetailsViewController.tripDelegate = self
        view.addSubview(tripDetailsViewController.view)
        tripDetailsViewController.didMove(toParentViewController: self)
        onViewOpened(scene.tripId)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return view.frame.width + 120
    }
    
    func segueToContainer() {
        performSegue(withIdentifier: "ListToContainer", sender: self)
    }

}
