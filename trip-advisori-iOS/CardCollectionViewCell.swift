//
//  CardCollectionViewCell.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 5/22/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//

import UIKit


class CardCollectionViewCell: UICollectionViewCell {
    private let cardService:CardService = Injector.sharedInjector.getCardService()
    
    func bindCard(card: Card) {
        var cardView:IAmACard = cardService.getView(card.nibId!)
        cardView.card = card
        cardView.bindCard()
        self.addSubview(cardView as! UIView)
    }

}
