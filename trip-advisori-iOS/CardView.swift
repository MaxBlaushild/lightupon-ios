//
//  CardView.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 7/5/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//

import UIKit

class CardView: UIView {
    private var _card_:Card!
    private var _nextScene_: Scene!

    var card: Card {
        get {
            return self._card_
        }
        
        set(newCard) {
            self._card_ = newCard
        }
    }
    
    var nextScene: Scene {
        get {
            return self._nextScene_
        }
        
        set(newScene) {
            self._nextScene_ = newScene
        }
    }

}
