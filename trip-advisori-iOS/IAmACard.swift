//
//  File.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 6/1/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//

import Foundation

protocol IAmACard {
    var card: Card { get set }
    func bindCard() -> Void
}