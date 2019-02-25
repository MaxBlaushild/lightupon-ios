//
//  DateExtensions.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 10/2/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//

import Foundation

extension Date {
    func hour() -> Int {
        let calendar = Calendar.current
        let components = (calendar as NSCalendar).components(.hour, from: self)
        let hour = components.hour
        
        return hour!
    }
    
    
    func minute() -> Int {
        let calendar = Calendar.current
        let components = (calendar as NSCalendar).components(.minute, from: self)
        let minute = components.minute
        
        return minute!
    }
    
    func day() -> Int {
        let calendar = Calendar.current
        let components = (calendar as NSCalendar).components(.day, from: self)
        let day = components.day
        
        return day!
    }
    
    func month() -> Int {
        let calendar = Calendar.current
        let components = (calendar as NSCalendar).components(.month, from: self)
        let month = components.month
        
        return month!
    }
    
    func daysSince() -> Int {
        let now = Date()
        let calendar = Calendar.current
        let components = (calendar as NSCalendar).components([.day], from: self, to: now, options: [])
        return components.day!
    }
    
    func minutesSince() -> Int {
        let now = Date()
        let calendar = Calendar.current
        let components = (calendar as NSCalendar).components([.minute], from: self, to: now, options: [])
        return components.minute!
    }
    
    func secondsSince() -> Int {
        let now = Date()
        let calendar = Calendar.current
        let components = (calendar as NSCalendar).components([.second], from: self, to: now, options: [])
        return components.second!
    }
    
    func hoursSince() -> Int {
        let now = Date()
        let calendar = Calendar.current
        let components = (calendar as NSCalendar).components([.hour], from: self, to: now, options: [])
        return components.hour!
    }
    
    func monthsSince() -> Int {
        let now = Date()
        let calendar = Calendar.current
        let components = (calendar as NSCalendar).components([.month], from: self, to: now, options: [])
        return components.month!
    }
    
    func yearsSince() -> Int {
        let now = Date()
        let calendar = Calendar.current
        let components = (calendar as NSCalendar).components([.year], from: self, to: now, options: [])
        return components.year!
    }

}
