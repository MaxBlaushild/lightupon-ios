//
//  File.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 5/11/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//

import Foundation

@objc protocol Injectable {
    var injector: Injector { get set }
    func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
}