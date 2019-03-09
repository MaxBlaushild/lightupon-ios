//
//  StoryTellerMenuViewController.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 7/5/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//

import UIKit

let cellReuseIdentifier = "QuestLogItem"

class QuestLogViewController: UIViewController, ProfileViewDelegate, UITableViewDelegate, UITableViewDataSource {
    
    fileprivate let userService: UserService = Services.shared.getUserService()
    fileprivate let questService: QuestService = Services.shared.getQuestService()
    
    fileprivate var quests = [Quest]()

    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var questLog: UITableView!
    
    fileprivate var profileView: ProfileView!
    fileprivate var xBackButton:XBackButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindProfile()
        makeProfileClickable()
        getQuests()
        configureQuestLog()
        
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
    
    func configureQuestLog() {
        questLog.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        questLog.delegate = self
        questLog.dataSource = self
    }
    
    func bindProfile() {
        profilePicture.imageFromUrl(userService.currentUser.profilePictureURL)
        nameLabel.text = userService.currentUser.fullName
        profilePicture.makeCircle()
    }
    
    func getQuests() {
        questService
            .getActiveQuests()
            .then({ _quests in
                self.quests = _quests
                self.questLog.reloadData()
            })
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return quests.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = questLog.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as UITableViewCell!
        let quest = quests[indexPath.row]
        cell.textLabel?.text = "\(quest.title) \(quest.questProgress.completedPosts)/\(quest.posts.count)"
        cell.textLabel?.font = UIFont(name: "Gotham", size: 14)
        return cell
    }
    

    func goBack(){
        dismiss(animated: true, completion: {})
    }
    
    func makeProfileClickable() {
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(QuestLogViewController.imageTapped(_:)))
        profilePicture.isUserInteractionEnabled = true
        profilePicture.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func imageTapped(_ img: AnyObject) {
        profileView = ProfileView.fromNib("ProfileView")
        profileView.frame = view.frame
        profileView.delegate = self
        profileView.initializeView(userService.currentUser.id)
        view.addSubview(profileView)
        addXBackButton()
    }
    
    func onLoggedOut() {
        self.performSegue(withIdentifier: "StoryTellerMenuToHome", sender: nil)
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
    
}
