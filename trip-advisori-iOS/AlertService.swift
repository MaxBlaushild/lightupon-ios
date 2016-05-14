//
//  AlertService.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 5/9/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//

import UIKit

class AlertService: Service {
    
    func openAlert(title: String, message: String, view: UIViewController) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        
        let cancelAction = UIAlertAction(title: "Cool", style: .Cancel) { (_) in }
        
        alert.addAction(cancelAction)
        
        view.presentViewController(alert, animated: true){}
    }
    
   
}
