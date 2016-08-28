//
//  TextHero.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 6/1/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//

import UIKit

class TextHero: UIView, IAmCardContents {
    @IBOutlet weak var textHero: UILabel!
    
    func bindCard(card: Card) {
        textHero.text = card.text
    }

}
