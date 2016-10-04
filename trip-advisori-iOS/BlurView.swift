//
//  BlurView.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 9/14/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//

import UIKit

class BlurView: UIVisualEffectView {
    
    fileprivate let _onClick:() -> Void
    
    init(onClick: @escaping () -> Void) {
        _onClick = onClick
        super.init(effect: UIBlurEffect(style: UIBlurEffectStyle.light))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        _onClick()
    }

}
