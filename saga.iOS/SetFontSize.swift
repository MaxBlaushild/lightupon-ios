//
//  SetFontSize.swift
//  Lightupon
//
//  Created by Blaushild, Max on 2/10/17.
//  Copyright © 2017 Blaushild, Max. All rights reserved.
//

import Foundation

extension UITextView {
    func setFontSize(size: CGFloat) {
        self.font =  UIFont(name: (self.font?.fontName)!, size: size)
    }
}
