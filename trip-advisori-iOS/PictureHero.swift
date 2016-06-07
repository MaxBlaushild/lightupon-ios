//
//  PictureHero.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 6/2/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//

import UIKit

class PictureHero: UIView, IAmACard {
    private var _card_:Card!
    
    @IBOutlet weak var pictureHero: UIImageView!
    
    @IBOutlet weak var labely: UILabel!
    @IBAction func buttonPress(sender: AnyObject) {
        labely.text = "pressed"
    }
    var card: Card {
        get {
            return self._card_
        }
        
        set(newCard) {
            self._card_ = newCard
        }
    }
    
    func bindCard() {
        pictureHero.imageFromUrl(_card_.imageUrl!)
    }

}
