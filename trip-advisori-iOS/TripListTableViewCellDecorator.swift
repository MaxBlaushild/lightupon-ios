//
//  TripListTableViewCellDecorator.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 2/7/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//

import UIKit

class TripListTableViewCellDecorator: NSObject {
    
    func decorateCell(cell:TripListTableViewCell, trip: Trip) {
        
        cell.tripImage.imageFromUrl(trip.imageUrl!)
        cell.tripTitle.text = trip.title
        cell.tripDescription.text = trip.descriptionText
        cell.tag = trip.id!
        cell.estimatedTime.text = trip.estimatedTime
        
    }

}
