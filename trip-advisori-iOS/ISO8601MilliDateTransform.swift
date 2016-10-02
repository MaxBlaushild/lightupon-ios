//
//  ISO8601MilliDateTransform.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 10/2/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//

import Foundation
import ObjectMapper

class ISO8601MilliDateTransform: DateFormatterTransform {
    init() {
        let formatter = NSDateFormatter()
        formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        
        super.init(dateFormatter: formatter)
    }
}
