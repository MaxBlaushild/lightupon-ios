//
//  CircularImageView.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 7/29/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//

import Foundation

extension UIImageView {
    func makeCircle() {
        self.layer.cornerRadius = self.frame.size.width / 2;
        self.clipsToBounds = true;
    }
}