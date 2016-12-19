//
//  TripListTableViewCell.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 2/7/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//

import UIKit

class TripListTableViewCell: UITableViewCell {
    @IBOutlet weak var tripTitle: UILabel!
    @IBOutlet weak var tripDescription: UILabel!
    @IBOutlet weak var tripImage: UIImageView!
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var daysSince: UILabel!
    @IBOutlet weak var userName: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func decorateCell(_ trip: Trip) {
        contentView.layer.borderColor = UIColor(red: CGFloat(153.00)/255, green: CGFloat(153.00)/255, blue: CGFloat(153.00)/255, alpha: 0.5).cgColor;
        contentView.layer.borderWidth = 1;
        userName.text = trip.owner?.fullName
        daysSince.text = trip.prettyTimeSinceCreation()
        tripTitle.text = trip.title
        tripDescription.text = trip.descriptionText
        tag = trip.id!
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
