//
//  RoundCorners.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 9/24/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//

import Foundation

extension UIView {
    func roundCorners() {
        self.layer.cornerRadius = 6
        self.layer.masksToBounds = true
    }
}