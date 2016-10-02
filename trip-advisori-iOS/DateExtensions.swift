//
//  DateExtensions.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 10/2/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//

import Foundation

extension NSDate {
    func hour() -> Int {
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components(.Hour, fromDate: self)
        let hour = components.hour
        
        return hour
    }
    
    
    func minute() -> Int {
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components(.Minute, fromDate: self)
        let minute = components.minute
        
        return minute
    }
    
    func day() -> Int {
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components(.Day, fromDate: self)
        let day = components.day
        
        return day
    }
    
    func month() -> Int {
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components(.Month, fromDate: self)
        let month = components.month
        
        return month
    }
    
    func daysSince() -> Int {
        let now = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Day], fromDate: self, toDate: now, options: [])
        return components.day
    }
    
    func minutesSince() -> Int {
        let now = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Minute], fromDate: self, toDate: now, options: [])
        return components.minute
    }
    
    func secondsSince() -> Int {
        let now = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Second], fromDate: self, toDate: now, options: [])
        return components.second
    }
    
    func hoursSince() -> Int {
        let now = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Hour], fromDate: self, toDate: now, options: [])
        return components.hour
    }
    
    func monthsSince() -> Int {
        let now = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Month], fromDate: self, toDate: now, options: [])
        return components.month
    }
    
    func yearsSince() -> Int {
        let now = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Year], fromDate: self, toDate: now, options: [])
        return components.year
    }

}