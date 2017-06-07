//
//  CommentCollectionViewCell.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 12/20/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//

import UIKit

class CommentCollectionViewCell: UICollectionViewCell {
    

    @IBOutlet weak var profilePictureView: UIImageView!
    @IBOutlet weak var commentLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setComment(comment: Comment) {
        let ownerNameText = comment.owner!.fullName
        let fullNameFont = [NSFontAttributeName: UIFont(name: "GothamRounded-Medium", size: 13.00)]
        let fullNameString = NSMutableAttributedString(string: ownerNameText, attributes: fullNameFont)
        
        let commentText = " \(comment.text!)"
        let commentString = NSMutableAttributedString(string: commentText)
        
        fullNameString.append(commentString)
        
        commentLabel.attributedText = fullNameString
    }

}
