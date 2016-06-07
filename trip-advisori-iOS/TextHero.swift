//
//  TextHero.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 6/1/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//

import UIKit

class TextHero: UIView, IAmACard {
    private var _card_:Card!
    
    @IBOutlet weak var textHero: UILabel!
    
    var card: Card {
        get {
            return self._card_
        }
        
        set(newCard) {
            self._card_ = newCard
        }
    }
    
    func bindCard() {
        textHero.text = _card_.text
    }

}
