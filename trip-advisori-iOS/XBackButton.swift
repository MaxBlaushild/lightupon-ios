//
//  XBackButton.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 9/14/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//

import UIKit

class XBackButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addShadow()
        self.setBackgroundImage(UIImage(named: "backButton"), forState: .Normal)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
