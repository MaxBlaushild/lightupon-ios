//
//  CursorPosition.swift
//  Lightupon
//
//  Created by Blaushild, Max on 6/5/17.
//  Copyright © 2017 Blaushild, Max. All rights reserved.
//

import Foundation

extension UITextView {
    var cursorPosition: CGRect? {
        get {
            if let selectedRange = self.selectedTextRange {
                let caretRect = self.caretRect(for: selectedRange.end)
                return self.convert(caretRect, to: nil)
            } else {
                return nil
            }
        }
    }
}
