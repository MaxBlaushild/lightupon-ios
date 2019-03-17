//
//  CardViewController.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 12/21/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//

import UIKit
import CoreLocation
import Observable

@objc protocol CardViewControllerDelegate {
    func onDismissed () -> Void
    func createProfileView (userID: Int) -> Void
}

enum PostState {
    case trackable
    case tracked
    case completable
    case completed
}

class CardViewController: UIViewController, ProfileViewCreator, CurrentLocationServiceDelegate {

    let postService = Services.shared.getPostService()
    let currentLocationService = Services.shared.getCurrentLocationService()
    let questService = Services.shared.getQuestService()
    
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var sceneImageView: UIImageView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var sceneTitleLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var timeSinceLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var overlay: UIView!
    @IBOutlet weak var beltOverlay: UIView!
    @IBOutlet weak var overlayTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var sceneImageHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var completeButton: UIButton!
    
    var delegate: CardViewControllerDelegate!
    var postID: Int = 0
    var location: CLLocation = CLLocation(latitude: 0, longitude: 0)
    var postState: PostState = .trackable
    var questID = 0
    var disposable: Disposable!
    
    func bindContext(post: Post, blurApplies: Bool) {
        setCanTrackState()
        sceneImageView.imageFromUrl(post.imageUrl)
        postID = post.id
        
        profileImageView.imageFromUrl(post.owner!.profilePictureURL, success: { img in
            self.profileImageView.image = img
            self.profileImageView.makeCircle()
        })
        
        if post.completed {
            setCompletedState()
        }
        
        currentLocationService.registerDelegate(self)
        location = post.cllocation
        questID = post.questID
        sceneTitleLabel.text = post.name
        timeSinceLabel.text = post.prettyTimeSinceCreation()
        addressLabel.text = "\(post.streetNumber) \(post.route)"
        descriptionLabel.attributedText = createBylineText(username: post.owner!.fullName, caption: post.caption)
        
        disposable = questService.observeFocusChanges({ focusedQuest in
            if let quest = focusedQuest.quest {
                if self.questID == quest.id {
                    self.setTrackingState()
                }
            }
        })
    }

    func onLocationUpdated() {
        let currentLocation = currentLocationService.location
        
        if postState == .completed {
            let distance = location.distance(from: currentLocation.cllocation)

            if (distance < 20) {
                setCanCompleteState()
            } else {
                setCanTrackState()
            }
        }
    }
    
    @IBAction func onCompletionPress(_ sender: Any) {
        switch postState {
        case .completable:
            completePost()
        case .trackable:
            trackPost()
        default:
            print("")
        }
    }
    
    func completePost() {
        postService.completePost(postID: postID).then { _ in
            self.setCompletedState()
        }
    }
    
    func trackPost() {
        questService.trackNewQuest(questID: questID).then {
            self.setTrackingState()
        }
    }
    
    func setCanCompleteState() {
        completeButton.setTitle("COMPLETE", for: .normal)
        completeButton.backgroundColor = UIColor.basePurple
        postState = .completable
    }
    
    func setCanTrackState() {
        completeButton.setTitle("TRACK", for: .normal)
        completeButton.backgroundColor = UIColor.basePurple
        postState = .trackable
    }
    
    func setCompletedState() {
        completeButton.setTitle("COMPLETED", for: .normal)
        completeButton.isEnabled = false
        completeButton.backgroundColor = UIColor.gray
        completeButton.alpha = 0.6
        postState = .completed
    }
    
    func setTrackingState() {
        completeButton.setTitle("TRACKING", for: .normal)
        completeButton.isEnabled = false
        completeButton.backgroundColor = UIColor.gray
        completeButton.alpha = 0.6
        postState = .tracked
    }
    
    func createProfileView(_ userId: Int) {
        delegate.createProfileView(userID: userId)
    }
    
    func setBottomViewHeight(newHeight: CGFloat) {
        bottomViewTopConstraint.constant = newHeight
    }
    
    func setStartingBottomViewHeight() {
        let startingHeight = sceneImageView.frame.height * -1.0
        bottomViewTopConstraint.constant = startingHeight
    }
    
    func setOverlayAlpha(alpha: CGFloat) {
        overlay.alpha = alpha
    }
    
    @IBAction func close(_ sender: Any) {
        delegate.onDismissed()
    }
    
    func createBylineText(username: String, caption: String) -> NSMutableAttributedString {
        let formattedString = NSMutableAttributedString()
        let bold = [NSFontAttributeName : UIFont(name: "GothamRounded-Medium", size: 17)!]
        let boldPart = NSMutableAttributedString(string:"\(username) ", attributes:bold)
        
        formattedString.append(boldPart)
        let normal = [NSFontAttributeName : descriptionLabel.font]
        let normalPart = NSMutableAttributedString(string: caption, attributes: normal)
        formattedString.append(normalPart)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 3
        
        formattedString.addAttribute(NSParagraphStyleAttributeName, value:paragraphStyle, range:NSMakeRange(0, formattedString.length))
        return formattedString
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
