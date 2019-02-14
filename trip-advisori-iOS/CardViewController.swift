//
//  CardViewController.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 12/21/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//

import UIKit

@objc protocol CardViewControllerDelegate {
    func onDismissed () -> Void
    func createProfileView (userID: Int) -> Void
}

class CardViewController: UIViewController, ProfileViewCreator {
    
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
    
    var delegate: CardViewControllerDelegate!
    
    func bindContext(post: Post, blurApplies: Bool) {
        sceneImageView.imageFromUrl(post.imageUrl)
        
        profileImageView.imageFromUrl(post.owner!.profilePictureURL, success: { img in
            self.profileImageView.image = img
            self.profileImageView.makeCircle()
        })
        
        sceneTitleLabel.text = post.name
        timeSinceLabel.text = post.prettyTimeSinceCreation()
        addressLabel.text = "\(post.streetNumber) \(post.route)"
        descriptionLabel.attributedText = createBylineText(username: post.owner!.fullName, caption: post.caption)
        beltOverlay.backgroundColor = UIColor.basePurple
        overlay.backgroundColor = UIColor.basePurple
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
