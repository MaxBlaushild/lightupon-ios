//
//  StringEscaping.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 7/20/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//

import Foundation

extension String {
    func replace(string:String, replacement:String) -> String {
        return self.stringByReplacingOccurrencesOfString(string, withString: replacement, options: NSStringCompareOptions.LiteralSearch, range: nil)
    }
    
    func removeWhitespace() -> String {
        return self.replace(" ", replacement: "")
    }
}