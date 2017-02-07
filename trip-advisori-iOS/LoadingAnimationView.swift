//
//  LoadingAnimationView.swift
//  Lightupon
//
//  Created by Blaushild, Max on 1/29/17.
//  Copyright © 2017 Blaushild, Max. All rights reserved.
//

import UIKit

protocol LoadingAnimationViewDelegate {
    func dismissLoadingView() -> Void
}

class LoadingAnimationView: UIView {

    @IBOutlet weak var thirdDot: UIView!
    @IBOutlet weak var firstDot: UIView!
    @IBOutlet weak var secondDot: UIView!
    @IBOutlet weak var lightuponLabel: UILabel!
    
    var delegate: LoadingAnimationViewDelegate!

    func initialize(parentView: LoadingAnimationViewDelegate) {
        firstDot.backgroundColor = Colors.basePurple
        secondDot.backgroundColor = Colors.basePurple
        thirdDot.backgroundColor = Colors.basePurple
        lightuponLabel.textColor = Colors.basePurple
        firstDot.makeCircle()
        secondDot.makeCircle()
        thirdDot.makeCircle()
        
        delegate = parentView
    }
    
    func animate() {
        grow(dot: firstDot, completion: { _ in
            self.shrink(dot: self.firstDot)
            self.grow(dot: self.secondDot, completion: { _ in
                self.shrink(dot: self.secondDot)
                self.grow(dot: self.thirdDot, completion: { _ in
                    self.shrink(dot: self.thirdDot)
                    self.grow(dot: self.secondDot, completion: { _ in
                        self.animateInLabel()
                    })
                })
            })
        })
        
    }
    
    func animateInLabel() {
        UIView.animate(withDuration: 0.5, animations: {
            self.lightuponLabel.alpha = 1.0
        }, completion: { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                self.delegate.dismissLoadingView()
            })
        })
    }
    
    func grow(dot: UIView, completion: @escaping (Bool) -> Void) {
        UIView.animate(withDuration: 0.4, animations: {
            dot.transform = CGAffineTransform(scaleX: 1.75, y: 1.75)
        }, completion: completion)
    }
    
    func shrink(dot: UIView) {
        UIView.animate(withDuration: 0.4, animations: {
            dot.transform = CGAffineTransform.identity
        })
    }

}
