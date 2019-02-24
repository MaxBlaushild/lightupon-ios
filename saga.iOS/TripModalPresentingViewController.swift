//
//  TripModalPresentingViewController.swift
//  Lightupon
//
//  Created by Blaushild, Max on 3/2/17.
//  Copyright © 2017 Blaushild, Max. All rights reserved.
//

import UIKit

class TripModalPresentingViewController: UIViewController, TripNameModalDelegate {
    
    var tripNameModal: TripNameModal!
    var blurView: UIVisualEffectView!
    var tripExplanationLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func openTripModal() {
        addBlurView()
        addTripModal()
        addExplanationText()
    }
    
    func onTripNameSaved(_ trip: Trip) {
        tripNameModal.removeFromSuperview()
        tripNameModal = nil
        blurView.removeFromSuperview()
        blurView = nil
        tripExplanationLabel.removeFromSuperview()
        tripExplanationLabel = nil
    }
    

    func addBlurView() {
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.light)
        blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = view.bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(blurView)
    }
    
    func addExplanationText() {
        tripExplanationLabel = UILabel()
        tripExplanationLabel.textColor = UIColor.mediumGrey
        tripExplanationLabel.font = UIFont(name: "GothamRounded-Book", size: 14)
        tripExplanationLabel.text = "By creating a trip, while lit, you can string together all of your experiences into one story. If not, drop moments for all of your friends to see!"
        tripExplanationLabel.numberOfLines = 0
        tripExplanationLabel.textAlignment = .center
        tripExplanationLabel.frame = CGRect(
            x: tripNameModal.frame.origin.x,
            y: tripNameModal.frame.origin.y + tripNameModal.frame.height + 20,
            width: tripNameModal.frame.width,
            height: tripNameModal.frame.height)
        view.addSubview(tripExplanationLabel)
        tripExplanationLabel.sizeToFit()
    }
    
    func addTripModal() {
        tripNameModal = TripNameModal.fromNib("TripNameModal")
        tripNameModal.delegate = self
        tripNameModal.frame = CGRect(
            x: (self.view.frame.width - 300) / 2,
            y: ((self.view.frame.height / 2) - 250) / 2,
            width: 300,
            height: 250
        )
        tripNameModal.transform = CGAffineTransform(scaleX: 0, y: 0)
        view.addSubview(tripNameModal)
        tripNameModal.initialize()
        animateInTripModal()
    }
    
    func animateInTripModal() {
        UIView.animate(withDuration: 0.25, animations: {
            self.tripNameModal.transform = .identity
        }, completion: { _ in
            self.tripNameModal.setTripNameEditabledState()
        })
    }

}
