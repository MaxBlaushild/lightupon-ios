//
//  CardView.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 7/5/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//

import UIKit
import MDCSwipeToChoose

class CardView: MDCSwipeToChooseView {
    
    private var _card:Card
    
    init(card: Card, options: MDCSwipeToChooseViewOptions, frame: CGRect) {
        _card = card
        super.init(frame: frame, options: options)
        loadCardContents()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static func getCardContents(nibId: String) -> IAmCardContents {
        switch nibId {
        case "TextHero":
            return TextHero.fromNib("TextHero")
        case "PictureHero":
            return PictureHero.fromNib("PictureHero")
        case "ComboTitle":
            return ComboTitle.fromNib("ComboTitle")
        default:
            return TextHero.fromNib("TextHero")
        }
    }
    
    static func createCardContents(card: Card) -> UIView {
        let cardContents:IAmCardContents = CardView.getCardContents(card.nibId!)
        cardContents.bindCard(card)
        return cardContents as! UIView
    }
    
    func loadCardContents() {
        let cardContentView = CardView.createCardContents(_card)
        cardContentView.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        self.addSubview(cardContentView)
    }
}
