//
//  TopViewController.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 3/13/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//

import UIKit

extension UIViewController {
    func topMostController()-> UIViewController {
        var topController = UIApplication.sharedApplication().keyWindow?.rootViewController
        
        while((topController?.presentedViewController) != nil){
            topController = topController?.presentedViewController
        }
        if(topController != nil){
            return topController!
        }
        else{
            return self
        }
        
    }
}