//
//  PictureHero.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 6/2/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//

import UIKit

class PictureHero: UIView, IAmCardContents {
    
    @IBOutlet weak var pictureHero: UIImageView!
    
    func bindCard(_ card: Card) {
        pictureHero.imageFromUrl(card.imageUrl!)
    }

}
