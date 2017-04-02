//
//  PlaceholderTextFieldColor.swift
//  Lightupon
//
//  Created by Blaushild, Max on 2/14/17.
//  Copyright © 2017 Blaushild, Max. All rights reserved.
//

import Foundation

extension UITextField{
    var placeHolderColor: UIColor? {
        get {
            return self.placeHolderColor
        }
        set {
            self.attributedPlaceholder = NSAttributedString(string:self.placeholder != nil ? self.placeholder! : "", attributes:[NSForegroundColorAttributeName: newValue!])
        }
    }
}
