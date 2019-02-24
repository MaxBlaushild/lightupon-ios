//
//  ViewFrame.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 9/24/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//

import Foundation

extension UIImage {
    static func frame(_ size: CGSize, color: CGColor) -> UIImage {
        let bounds = CGRect(origin: CGPoint.zero, size: size)
        let opaque = false
        let scale: CGFloat = 0
        UIGraphicsBeginImageContextWithOptions(size, opaque, scale)
        let context = UIGraphicsGetCurrentContext()
        
        // Setup complete, do drawing here
        context?.setStrokeColor(color)
        context?.setLineWidth(12.0)
        
        context?.stroke(bounds)
        
        context?.beginPath()
        context?.move(to: CGPoint(x: bounds.minX, y: bounds.minY))
        context?.move(to: CGPoint(x: bounds.maxX, y: bounds.minY))
        context?.addLine(to: CGPoint(x: bounds.maxX, y: bounds.maxY))
        context?.addLine(to: CGPoint(x: bounds.minX, y: bounds.maxY))
        context?.move(to: CGPoint(x: bounds.minX, y: bounds.minY))
        context?.strokePath()
        
        // Drawing complete, retrieve the finished image and cleanup
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}
