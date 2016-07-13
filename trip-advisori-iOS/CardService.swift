//
//  CardService.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 6/2/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//

import UIKit

class CardService: Service {
    func getView(nibId: String) -> IAmACard {
        switch nibId {
        case "TextHero":
            return TextHero.fromNib("TextHero")
        case "PictureHero":
            return PictureHero.fromNib("PictureHero")
        case "MapHero":
            return MapHero.fromNib("MapHero")
        default:
            return TextHero.fromNib("TextHero")
        }
    }
}
