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
    public func imageFromUrl(_ urlString: String) {
        self.image = nil
        let nsurl = URL(string: urlString)
        self.hnk_setImageFromURL(nsurl!)
    }
    
    public func imageFromUrl(_ urlString: String, success: @escaping (UIImage) -> Void) {
        self.image = nil
        let nsurl = URL(string: urlString)
        self.hnk_setImageFromURL(nsurl!, success: success)
    }
}
