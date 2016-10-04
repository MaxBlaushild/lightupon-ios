//
//  CardSwipeOptions.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 9/7/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//

import UIKit
import MDCSwipeToChoose

class CardSwipeOptions: MDCSwipeToChooseViewOptions {
    override init() {
        super.init()
        self.likedText = nil
        self.likedColor = UIColor.clear
        self.nopeText = nil
        self.nopeColor = UIColor.clear
    }
}
