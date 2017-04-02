//
//  TripNameModal.swift
//  Lightupon
//
//  Created by Blaushild, Max on 2/19/17.
//  Copyright © 2017 Blaushild, Max. All rights reserved.
//

import UIKit

protocol TripNameModalDelegate {
    func onTripNameSaved(_ trip: Trip) -> Void
}

class TripNameModal: UIView, UITextFieldDelegate, UITextViewDelegate {
    
    let tripService = Services.shared.getTripsService()
    let litService = Services.shared.getLitService()
    
    @IBOutlet weak var descriptionLine: UIView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var tripNameLabel: UILabel!
    @IBOutlet weak var tripNameTextField: UITextField!
    
    var delegate: TripNameModalDelegate!
    
    func initialize() {
        roundCorners()
        makeLabelsTouchable()
//        tripNameLabel.tintColor = UIColor.white
        tripNameTextField.delegate = self
        descriptionTextView.delegate = self
    }
    
    @IBAction func saveTripName(_ sender: Any) {
        save()
    }
    
    func save() {
        let title = tripNameTextField.text!
        let details = descriptionTextView.text!
        let trip = Trip(title: title, details: details)
        tripService.createTrip(trip, callback: self.onSaved)
    }
    
    func onSaved(_ trip: Trip) {
        litService.light {
            self.delegate.onTripNameSaved(trip)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        setDescriptionEditabledState()
        return true;
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            save()
            return false
        }
        return true
    }
    
    func makeLabelsTouchable() {
        let gestureTwo = UITapGestureRecognizer(target: self, action:  #selector(setDescriptionEditabledState))
        descriptionLabel.addGestureRecognizer(gestureTwo)
        descriptionLabel.isUserInteractionEnabled = true
    }
    
    func setTripNameEditabledState() {
        UIView.animate(withDuration: 0.5, animations: {
            self.tripNameLabel.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            self.tripNameLabel.frame.origin = CGPoint(x: 20, y: self.tripNameTextField.frame.origin.y - self.tripNameLabel.frame.height - 5)
        }, completion: { _ in
            self.tripNameLabel.isUserInteractionEnabled = false
            self.tripNameTextField.isEnabled = true
            self.tripNameTextField.becomeFirstResponder()
        })
    }
    
    func setDescriptionEditabledState() {
        UIView.animate(withDuration: 0.5, animations: {
            self.descriptionLabel.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            self.descriptionLabel.frame.origin = CGPoint(x: 20, y: self.frame.height / 2 - self.descriptionLabel.frame.height)
            self.descriptionLine.alpha = 0.0
        }, completion: { _ in
            self.descriptionLabel.isUserInteractionEnabled = false
            self.descriptionTextView.isEditable = true
            self.descriptionTextView.becomeFirstResponder()
        })
    }
    
}
