//
//  RoundDoubles.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 12/29/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//

import Foundation

extension Double {
    /// Rounds the double to decimal places value
    func roundTo(places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
