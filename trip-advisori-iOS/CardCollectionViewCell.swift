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
    
    func bindCard(card: Card, nextScene: Scene) {
        var cardView:IAmACard = cardService.getView(card.nibId!)
        cardView.card = card
        cardView.nextScene = nextScene
        cardView.bindCard()
        let castedCardView = cardView as! UIView
        sizeCardView(castedCardView)
        self.addSubview(castedCardView)
    }
    
    func sizeCardView(cardView: UIView) {
        let height = self.contentView.bounds.size.height
        let width = self.contentView.bounds.size.width
        cardView.frame = CGRect(x: 0, y: 0, width: width, height: height)
    }

}
