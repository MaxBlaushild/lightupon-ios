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
    @IBOutlet weak var estimatedTime: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func decorateCell(trip: Trip) {
//        let overlay: UIView = UIView(frame: CGRectMake(0, 0, tripImage.frame.size.width, tripImage.frame.size.height))
//        overlay.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.4)
        tripImage.imageFromUrl(trip.imageUrl!)
//        tripImage.addSubview(overlay)
        tripTitle.text = trip.title
        tripDescription.text = trip.descriptionText
        tag = trip.id!
        estimatedTime.text = trip.estimatedTime
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
