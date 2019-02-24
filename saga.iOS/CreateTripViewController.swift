//
//  CreateTripViewController.swift
//  Lightupon
//
//  Created by Blaushild, Max on 5/29/17.
//  Copyright © 2017 Blaushild, Max. All rights reserved.
//

import UIKit

protocol CreateTripViewControllerDelegate {
    func onTripCreated(_: Trip) -> Void
}

class CreateTripViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {
    
    private let tripsService = Services.shared.getTripsService()

    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var tripNameTextField: UITextField!
    @IBOutlet weak var tripNameBar: UIView!
    @IBOutlet weak var tripDescriptionTextView: UITextView!
    @IBOutlet weak var overlayView: UIView!
    @IBOutlet weak var doneButton: UIButton!
    
    var delegate: CreateTripViewControllerDelegate?
    
    var tripNameValid = false
    var tripDescriptionValid = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        watchForKeyTouch()
        
        tripNameTextField.delegate = self
        tripNameTextField.becomeFirstResponder()
        
        tripDescriptionTextView.textContainer.lineFragmentPadding = 0
        tripDescriptionTextView.textContainerInset = .zero
        tripDescriptionTextView.delegate = self
        
        doneButton.isEnabled = false
        doneButton.setTitleColor(.mediumGrey, for: .disabled)
        
        UITextField.appearance().tintColor = .basePurple
        tripDescriptionTextView.tintColor = .basePurple
        
        tripNameBar.layer.addBorder(edge: .bottom, color: .lightGray, thickness: 1.0)
        backButton.setImageTint(color: .black)
        tripNameTextField.attributedPlaceholder = NSAttributedString(string: "New Trip",
                                                                      attributes: [NSForegroundColorAttributeName: UIColor.basePurple])
    }
    
    func watchForKeyTouch() {
        let notificationCenter = NotificationCenter.default
        
        notificationCenter.addObserver(self,
                                       selector: #selector(onKeyPress),
                                       name: NSNotification.Name.UITextFieldTextDidChange,
                                       object: nil)
    }
    
    func onKeyPress(sender: AnyObject) {
        if let notification = sender as? NSNotification {
            let textFieldChanged = notification.object as? UITextField
            if textFieldChanged == self.tripNameTextField {
                tripNameValid =  self.tripNameTextField.text!.characters.count > 2
                overlayView.isHidden = tripNameValid
                doneButton.isEnabled = tripNameValid && tripDescriptionValid
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if tripNameValid {
            textField.resignFirstResponder()
            overlayView.isHidden = true
            tripDescriptionTextView.isEditable = true
            tripDescriptionTextView.becomeFirstResponder()
            tripDescriptionTextView.text = ""
        }

        return tripNameValid
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            save()
            return false
        }
        
        let proposedText = textView.text + text
        tripDescriptionValid = proposedText.characters.count > 2
        tripDescriptionValid = tripDescriptionValid && proposedText.characters.count < 156
        doneButton.isEnabled = tripNameValid && tripDescriptionValid
        
        return true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func goBack(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func submit(_ sender: Any) {
        save()
    }
    
    func save() {
        let title = tripNameTextField.text!
        let details = tripDescriptionTextView.text!
        let trip = Trip(title: title, details: details)
        tripsService.createTrip(trip, callback: self.onSaved)
    }
    
    func onSaved(_ trip: Trip) {
        dismiss(animated: true, completion: {
            if let delegate = self.delegate {
                delegate.onTripCreated(trip)
            }
        })
    }
}
    
