//
//  File.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 7/5/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//

import Foundation

protocol IAmACard {
    func bindCard() -> Void
    var card: Card { get set }
    var nextScene: Scene { get set }
}
