//
//  CircularButton.swift
//  Lightupon
//
//  Created by Blaushild, Max on 11/23/17.
//  Copyright © 2017 Blaushild, Max. All rights reserved.
//

import UIKit

class CircularButton: UIButton {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.layer.cornerRadius = 0.5 * self.bounds.size.width
        self.clipsToBounds = true
        self.addShadow()
    }

}
