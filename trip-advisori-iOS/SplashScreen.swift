//
//  SplashScreen.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 8/28/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//

import Foundation
import CBZSplashView

extension UIView {
    func splashView() {
        let icon = UIBezierPath.mainLogo()
        let splashView = CBZSplashView(bezierPath: icon, backgroundColor: Colors.basePurple)
        splashView?.animationDuration = 3
        self.addSubview(splashView!)
        splashView?.startAnimation()
    }
}
