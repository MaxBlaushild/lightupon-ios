//
//  StringEscaping.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 7/20/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//

import Foundation

extension String {
    func replace(_ string:String, replacement:String) -> String {
        return self.replacingOccurrences(of: string, with: replacement, options: NSString.CompareOptions.literal, range: nil)
    }
    
    func removeWhitespace() -> String {
        return self.replace(" ", replacement: "")
    }
}
