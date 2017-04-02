//
//  StoryTellerMenuViewController.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 7/5/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//

import UIKit


private let reuseIdentifier = "PartyMemberCollectionViewCell"

class StoryTellerMenuViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, SocketServiceDelegate, ProfileViewDelegate {
    
    fileprivate let partyService: PartyService = Services.shared.getPartyService()
    fileprivate let userService: UserService = Services.shared.getUserService()
    fileprivate let socketService: SocketService = Services.shared.getSocketService()

    @IBOutlet weak var partyMemberCollectionView: UICollectionView!
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var leavePartyButton: UIButton!
    
    fileprivate var _partyState: PartyState!
    fileprivate var _party: Party!
    
    fileprivate var profileView: ProfileView!
    fileprivate var xBackButton:XBackButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        leavePartyButton.isHidden = true
        socketService.registerDelegate(self)
        bindProfile()
        makeProfileClickable()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var shouldAutorotate : Bool {
        return false
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
    
    func bindProfile() {
        profilePicture.imageFromUrl(userService.currentUser.profilePictureURL!)
        nameLabel.text = userService.currentUser.fullName
        profilePicture.makeCircle()
    }
    
    func onResponseReceived(_ partyState: PartyState) {
        _partyState = partyState
        configurePartyCollectionView()
    }
    
    func bindParty(_ party: Party) {
        _party = party
        leavePartyButton.isHidden = false
    }
    func configurePartyCollectionView() {
        partyMemberCollectionView.dataSource = self
        partyMemberCollectionView.delegate = self
        partyMemberCollectionView.reloadData()
    }
    
//    func removeUserFromPartyList() {
//        for (index, partyMember) in _partyState.users!.enumerated() {
//            if partyMember.email == userService.currentUser.email {
//                _partyState.users?.remove(at: index)
//            }
//        }
//    }

    func goBack(){
        dismiss(animated: true, completion: {})
    }
    
    func makeProfileClickable() {
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(StoryTellerMenuViewController.imageTapped(_:)))
        profilePicture.isUserInteractionEnabled = true
        profilePicture.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func imageTapped(_ img: AnyObject) {
        profileView = ProfileView.fromNib("ProfileView")
        profileView.frame = view.frame
        profileView.delegate = self
        profileView.initializeView(userService.currentUser)
        view.addSubview(profileView)
        addXBackButton()
    }
    
    @IBAction func leaveParty(_ sender: AnyObject) {
        partyService.leaveParty({
            self.performSegue(withIdentifier: "StoryTellerMenuToHome", sender: nil)
        })
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func onLoggedOut() {
            self.performSegue(withIdentifier: "StoryTellerMenuToHome", sender: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        removeUserFromPartyList()
//        return _partyState.users!.count
        return 0
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
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let user: User = _partyState.users![(indexPath as NSIndexPath).row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
//
//        cell.bindCell(user)
        
        return cell
    }
}
