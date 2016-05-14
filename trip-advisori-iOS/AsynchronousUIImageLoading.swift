//
//  AsynchronousUIImageLoading.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 2/7/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//


import UIKit
import Alamofire

extension UIImageView {
    public func imageFromUrl(urlString: String) {
        Alamofire.request(.GET, urlString).response { (request, response, data, error) in
            self.image = UIImage(data: data!, scale:1)
        }
    }
}
