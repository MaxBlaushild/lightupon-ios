//
//  CardCollectionViewCell.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 5/22/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//

import UIKit

class CardCollectionViewCell: UICollectionViewCell {
    private var card: Card!
    @IBOutlet weak var cardLabel: UILabel!
    
    func setCard(_card_: Card) {
        card = _card_
        bindCard()
    }
    
    func bindCard() {
        cardLabel.text = card.text
    }
    
}
