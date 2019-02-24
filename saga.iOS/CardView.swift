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
    
    init(card: Card, scene: Scene, owner: User, options: MDCSwipeToChooseViewOptions, frame: CGRect) {
        super.init(frame: frame, options: options)
        loadCardContents(card, scene: scene, owner: owner)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static func getCardContents(_ nibId: String) -> DefaultCardDetailsView {
            return DefaultCardDetailsView.fromNib("DefaultCardDetailsView")
//        }
    }

    
    func loadCardContents(_ card: Card, scene: Scene, owner: User) {
        let cardContents = CardView.getCardContents(card.nibId!)
        cardContents.initFrom(card: card, owner: owner, scene: scene)
        cardContents.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        self.addSubview(cardContents)
    }
}
