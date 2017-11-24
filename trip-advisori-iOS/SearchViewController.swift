//
//  SearchViewController.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 10/25/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//

import UIKit

private let reuseIdentifier = "PartyMemberCollectionViewCell"

class SearchViewController: UIViewController,
                            UICollectionViewDelegate,
                            UICollectionViewDelegateFlowLayout,
                            UICollectionViewDataSource,
                            ProfileViewDelegate,
                            UITextFieldDelegate {
    
    fileprivate let _searchService = Services.shared.getSearchService()
    fileprivate let _followService = Services.shared.getFollowService()
    
    fileprivate var _users = [User]()
    
    fileprivate var profileView: ProfileView!
    fileprivate var xBackButton:XBackButton!

    @IBOutlet weak var searchBar: UITextField!
    @IBOutlet weak var buttonBarView: UIView!
    @IBOutlet weak var userCollectionView: UICollectionView!
    @IBOutlet weak var resultsButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        userCollectionView.dataSource = self
        userCollectionView.delegate = self
        searchBar.delegate = self
        
        setLeftView()
        watchForKeyTouch()
        
        styleBorders()
        makeKeyboardLeave()
    }
    
    func makeKeyboardLeave() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dissmissKeyboard))
        tap.cancelsTouchesInView = false
        
        view.addGestureRecognizer(tap)
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        animateInCancelButton()
        return true
    }
    
    func animateInCancelButton() {
        let offset = self.cancelButton.frame.width + 10
        UIView.animate(withDuration: 0.5, animations: {
            self.searchBar.frame = CGRect(
                x: self.searchBar.frame.origin.x,
                y: self.searchBar.frame.origin.y,
                width: self.searchBar.frame.width - offset,
                height: self.searchBar.frame.height
            )
            self.cancelButton.frame.origin.x = self.cancelButton.frame.origin.x - offset
        })
    }

    @IBAction func cancel(_ sender: Any) {
        resetResults()
        clearTextField()
        dismissKeyboard()
    }
    
    func resetResults() {
        _users = [User]()
        userCollectionView.reloadData()
        self.view.endEditing(true)
    }
    
    func clearTextField() {
        searchBar.text = ""
    }
    
    func dissmissKeyboard(sender: UITapGestureRecognizer) {
        dismissKeyboard()
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    func styleBorders() {
        buttonBarView.layer.addBorder(edge: UIRectEdge.top, color: UIColor.lightGray, thickness: 0.5)
        buttonBarView.layer.addBorder(edge: UIRectEdge.bottom, color: UIColor.lightGray, thickness: 0.5)
        resultsButton.layer.addBorder(edge: UIRectEdge.bottom, color: UIColor.black, thickness: 2.0)
    }
    
    func watchForKeyTouch() {
        let notificationCenter = NotificationCenter.default
        
        notificationCenter.addObserver(self,
        selector: #selector(SearchViewController.onKeyPress),
        name: NSNotification.Name.UITextFieldTextDidChange,
        object: nil)
    }
    
    func setLeftView() {
        let image = UIImage(named: "search")
        let imageView = UIImageView()
        imageView.frame = CGRect(x: 0, y: 0, width: 34, height: 10)
        imageView.contentMode = UIViewContentMode.right
        imageView.image = image
        searchBar.leftView = imageView
        searchBar.leftViewMode = .always
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func onKeyPress(sender: AnyObject) {
        if let notification = sender as? NSNotification {
            let textFieldChanged = notification.object as? UITextField
            if textFieldChanged == self.searchBar && (self.searchBar.text?.characters.count)! > 1 {
                search()
            }
        }
    }
    
    func search() {
        _searchService.findUsers(query: searchBar.text!, callback: self.onUsersRecieved)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true;
    }
    
    func onUsersRecieved(users: [User]) {
        _users = users
        userCollectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let user: User = _users[(indexPath as NSIndexPath).row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PartyMemberCollectionViewCell
        cell.bindCell(user)
        
        cell.partyMemberProfilePicture.imageFromUrl(user.profilePictureURL, success: { img in
            cell.partyMemberProfilePicture.makeCircle()
        })
        
        giveOffsetBorder(cell: cell)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return _users.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        profileView = ProfileView.fromNib("ProfileView")
        profileView.frame = view.frame
        profileView.delegate = self
        profileView.initializeView(_users[indexPath.row].id)
        view.addSubview(profileView)
        addXBackButton()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let kWhateverHeightYouWant = 75
        return CGSize(width: UIScreen.main.bounds.width, height: CGFloat(kWhateverHeightYouWant))
    }
    
    func giveOffsetBorder(cell: PartyMemberCollectionViewCell) {
        let border = CALayer()
        border.frame = CGRect.init(x: 94.5, y: cell.frame.height - 0.5, width: cell.frame.width - 94.5, height: 0.5)
        border.backgroundColor = UIColor.lightGray.cgColor
        cell.layer.addSublayer(border)
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

}
