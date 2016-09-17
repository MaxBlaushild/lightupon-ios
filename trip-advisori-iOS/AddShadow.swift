//
//  AddShadow.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 8/28/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//

import Foundation

extension UIView {
    func addShadow() {
        self.layer.shadowColor = UIColor.blackColor().CGColor
        self.layer.shadowOffset = CGSize(width: 0, height: 3)
        self.layer.shadowOpacity = 0.15
        self.layer.shadowRadius = 5
    }
}