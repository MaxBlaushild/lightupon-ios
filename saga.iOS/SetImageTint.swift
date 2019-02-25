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
    
        
//    func maskWithColor(color: UIColor) -> UIImage? {
//        let maskImage = cgImage!
//        
//        let width = size.width
//        let height = size.height
//        let bounds = CGRect(x: 0, y: 0, width: width, height: height)
//        
//        let colorSpace = CGColorSpaceCreateDeviceRGB()
//        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
//        let context = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)!
//        
//        context.clip(to: bounds, mask: maskImage)
//        context.setFillColor(color.cgColor)
//        context.fill(bounds)
//        
//        if let cgImage = context.makeImage() {
//            let coloredImage = UIImage(cgImage: cgImage)
//            return coloredImage
//        } else {
//            return nil
//        }
//    }
}
