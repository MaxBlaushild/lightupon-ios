//
//  ParentViewController.swift
//  Lightupon
//
//  Created by Blaushild, Max on 3/2/17.
//  Copyright © 2017 Blaushild, Max. All rights reserved.
//

import Foundation

extension UIView {
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}
