//
//  AsynchronousUIImageLoading.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 2/7/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//


import UIKit
import Alamofire
import Haneke

extension UIImageView {
    public func imageFromUrl(urlString: String) {
        self.image = nil
        let nsurl = NSURL(string: urlString)
        self.hnk_setImageFromURL(nsurl!)
    }
    
}