//
//  PostConfirmationView.swift
//  Lightupon
//
//  Created by Blaushild, Max on 2/20/17.
//  Copyright © 2017 Blaushild, Max. All rights reserved.
//

import UIKit

class PostConfirmationView: UIView {

    @IBOutlet weak var checkImageView: UIImageView!
    
    
    override func draw(_ rect: CGRect) {
        drawRingFittingInsideView()
    }
    
    internal func drawRingFittingInsideView()->() {
        let halfSize:CGFloat = checkImageView.frame.height
        let desiredLineWidth:CGFloat = 1    // your desired value
        
        let circlePath = UIBezierPath(
            arcCenter: checkImageView.center,
            radius: CGFloat( halfSize - (desiredLineWidth/2) ),
            startAngle: CGFloat(0),
            endAngle:CGFloat(M_PI * 2),
            clockwise: true)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = circlePath.cgPath
        
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = UIColor.basePurple.cgColor
        shapeLayer.lineWidth = desiredLineWidth
        
        layer.addSublayer(shapeLayer)
    }

}
