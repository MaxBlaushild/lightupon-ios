//
//  ArrayMethod.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 10/9/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//

import Foundation

extension Array {
    var secondLast: Element {
        return self[self.endIndex - 2]
    }
}
