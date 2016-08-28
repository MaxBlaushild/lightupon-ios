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
    
    static func getView(nibId: String) -> IAmCardContents {
        switch nibId {
        case "TextHero":
            return TextHero.fromNib("TextHero")
        case "PictureHero":
            return PictureHero.fromNib("PictureHero")
        default:
            return TextHero.fromNib("TextHero")
        }
    }
    
    func loadCardContents() {
        let cardContents:IAmCardContents = CardView.getView(_card.nibId!)
        cardContents.bindCard(_card)
        let cardContentView = cardContents as! UIView
        cardContentView.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        self.addSubview(cardContentView)
    }
    
    

}
