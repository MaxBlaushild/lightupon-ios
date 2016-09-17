//
//  BlurView.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 9/14/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//

import UIKit

class BlurView: UIVisualEffectView {
    
    private let _onClick:() -> Void
    
    init(onClick: () -> Void) {
        _onClick = onClick
        super.init(effect: UIBlurEffect(style: UIBlurEffectStyle.Light))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        _onClick()
    }

}
