//
//  ComboTitle.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 9/22/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//

import UIKit

class ComboTitle: UIView, IAmCardContents {

    @IBOutlet weak var descriptionText: UILabel!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var backgroundImage: UIImageView!
    
    func bindCard(_ card: Card) {
        title.text = card.text
        descriptionText.text = card.textTwo
        
        
        backgroundImage.imageFromUrl(card.imageUrl!)
    
    }
}
