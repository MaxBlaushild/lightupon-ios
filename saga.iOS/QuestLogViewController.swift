//
//  StoryTellerMenuViewController.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 7/5/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//

import UIKit
import Observable

let cellReuseIdentifier = "QuestLogItem"
let trackingQuestCopy = "You are currently tracking:"
let notTrackingCopy = "No quests being tracked"

class QuestLogViewController: UIViewController, ProfileViewDelegate, UITableViewDelegate, UITableViewDataSource {
    
    fileprivate let userService: UserService = Services.shared.getUserService()
    fileprivate let questService: QuestService = Services.shared.getQuestService()
    
    fileprivate var quests = [Quest]()

    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var questNameLabel: UILabel!
    @IBOutlet weak var questLog: UITableView!
    @IBOutlet weak var activeQuestHeight: NSLayoutConstraint!
    @IBOutlet weak var questTrackingLabel: UILabel!
    @IBOutlet weak var questLogSectionTop: NSLayoutConstraint!
    
    fileprivate var profileView: ProfileView!
    fileprivate var xBackButton: XBackButton!
    fileprivate var focusedQuestDisposable: Disposable!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindProfile()
        makeProfileClickable()
        getQuests()
        configureQuestLog()
        
        focusedQuestDisposable = questService.observeFocusChanges { focusedQuest in
            if let quest = focusedQuest.quest {
                let containsQuest = self.quests.contains { element in
                    return element.id == quest.id
                }
                
                if !containsQuest {
                    self.quests.append(quest)
                    self.questLog.reloadData()
                }
                
                self.questNameLabel.text = quest.title
                self.questTrackingLabel.text = trackingQuestCopy
                self.animateActiveQuestIn()

            } else {
                self.questNameLabel.text = ""
                self.questTrackingLabel.text = notTrackingCopy
                self.animateActiveQuestOut()
            }
        }
    }
    
    func animateActiveQuestIn() {
        questLogSectionTop.constant = 120
    }
    
    func animateActiveQuestOut() {
        questLogSectionTop.constant = 10
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
    
    @IBAction func onStopFocus(_ sender: Any) {
        questService.dropQuestFocus()
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
        cell.textLabel?.text = "\(quest.title) (\(quest.questProgress.completedPosts)/\(quest.posts.count))"
        cell.textLabel?.font = UIFont(name: "Gotham", size: 14)
        cell.textLabel?.textColor = UIColor.white
        cell.backgroundColor = UIColor.black
        cell.selectionStyle = .none
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let quest = quests[indexPath.row]
        questService.focusOnQuest(quest)
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
