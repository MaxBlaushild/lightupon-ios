//
//  TripDetailsView.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 9/11/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//

import UIKit

class DefaultCardDetailsView: UIView, BeltOverlayDelegate {
    fileprivate let tripsService: TripsService = Services.shared.getTripsService()
    fileprivate let partyService: PartyService = Services.shared.getPartyService()
    fileprivate let commentService: CommentService = Services.shared.getCommentService()
    
    fileprivate var tripId: Int?
    fileprivate var ownerId: Int?
    
    internal var delegate: ProfileViewCreator!
    
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var beltOverlayFrame: BeltOverlayView!
    @IBOutlet weak var cardImageView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    var beltOverlay: BeltOverlayView!
    
    func initFrom(card: Card, owner: User, scene: Scene) {
        cardImageView.imageFromUrl(card.imageUrl)

        let formattedString = createBylineText(username: "blaushmild", caption: card.caption)
        descriptionLabel.attributedText = formattedString
        
        let beltConfig = BeltConfig(scene: scene, card: card, owner: owner)
        initBelt(config: beltConfig)
    }
    
    func initBelt(config: BeltConfig) {
        beltOverlay = BeltOverlayView.fromNib()
        beltOverlayFrame.addSubview(beltOverlay)
        beltOverlay.frame = CGRect(x: 0, y: 0, width: beltOverlayFrame.frame.width, height: beltOverlayFrame.frame.height)
        beltOverlay.config = config
        beltOverlay.isHidden = false
        bringSubview(toFront: beltOverlay)
    }
    
    func initFrom(card: Card, blur: CGFloat, blurApplies: Bool) {
        cardImageView.imageFromUrl(card.imageUrl, success: { img in
            var image = img
            if blurApplies && blur > 0.001 {
                image = img.applyBackToTheFutureEffect(blur: blur)!
            }
            self.cardImageView.image = image
        })
        
        let formattedString = createBylineText(username: "blaushmild", caption: card.caption)
        descriptionLabel.attributedText = formattedString
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
//

    func createProfileView(sender: AnyObject) {
        if let userId = ownerId {
            delegate.createProfileView(userId)
        }
    }
    
    func setBottomViewHeight(newHeight: CGFloat) {
        bottomView.frame.origin.y = newHeight
    }
    
    func slideBeltOverlay(newHeight: CGFloat) {
        UIView.animate(withDuration: 0.5, animations: {
            self.beltOverlay.frame.origin.y = newHeight
        })
    }
    
    func shouldAutorotate() -> Bool {
        return false
    }
    
    func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
    

}
