//
//  SetImageTint.swift
//  Lightupon
//
//  Created by Blaushild, Max on 2/20/17.
//  Copyright © 2017 Blaushild, Max. All rights reserved.
//

import Foundation

extension UIButton {
    func setImageTint(color: UIColor) {
        let tintedImage = image(for: .normal)?.withRenderingMode(.alwaysTemplate)
        setImage(tintedImage, for: .normal)
        tintColor = color
    }
    
    func setImageTint(imageName: String, color: UIColor) {
        let origImage = UIImage(named: imageName)
        let tintedImage = origImage?.withRenderingMode(.alwaysTemplate)
        setImage(tintedImage, for: .normal)
        tintColor = color
    }
}
