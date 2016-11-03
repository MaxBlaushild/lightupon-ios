//
//  SearchViewController.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 10/25/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//

import UIKit

private let reuseIdentifier = "PartyMemberCollectionViewCell"

class SearchViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, ProfileViewDelegate {
    fileprivate let _searchService = Injector.sharedInjector.getSearchService()
    fileprivate let _followService = Injector.sharedInjector.getFollowService()
    
    fileprivate var _users = [User]()
    
    fileprivate var profileView: ProfileView!
    fileprivate var xBackButton:XBackButton!

    @IBOutlet weak var searchBar: UITextField!
    @IBOutlet weak var userCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        userCollectionView.dataSource = self
        userCollectionView.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func search(_ sender: AnyObject) {
        _searchService.findUsers(query: searchBar.text!, callback: self.onUsersRecieved)
    }
    
    func onUsersRecieved(users: [User]) {
        _users = users
        userCollectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return _users.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        profileView = ProfileView.fromNib("ProfileView")
        profileView.frame = view.frame
        profileView.delegate = self
        profileView.initializeView(_users[indexPath.row])
        view.addSubview(profileView)
        addXBackButton()
    }
    
    func onLoggedOut() {}
    
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
        let user: User = _users[(indexPath as NSIndexPath).row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PartyMemberCollectionViewCell
        
        cell.bindUser(user: user)
        
        return cell
    }

}
