//
//  TripListTableViewCell.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 2/7/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//

import UIKit

class TripListTableViewCell: UITableViewCell {
    @IBOutlet weak var tripTitle: UILabel! {
        didSet {
            tripTitle.font = UIFont(name: Fonts.dosisMedium, size: 18)
            tripTitle.textColor = UIColor.whiteColor()
        }
    }
    @IBOutlet weak var tripDescription: UILabel!{
        didSet {
            tripDescription.font = UIFont(name: Fonts.dosisMedium, size: 18)
            tripDescription.textColor = UIColor.whiteColor()
        }
    }
    @IBOutlet weak var tripImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBOutlet weak var estimatedTime: UILabel! {
        didSet {
            estimatedTime.font = UIFont(name: Fonts.dosisMedium, size: 18)
            estimatedTime.textColor = UIColor.whiteColor()
        }
    }
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    
    
    

}
