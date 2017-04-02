//
//  LightViewController.swift
//  Lightupon
//
//  Created by Blaushild, Max on 2/26/17.
//  Copyright © 2017 Blaushild, Max. All rights reserved.
//

import UIKit

class LightViewController: UIViewController {
    
    let tripsService = Services.shared.getTripsService()

    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var tripNameTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        backButton.setImageTint(imageName: "left_chevron", color: .darkGrey)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func createTrip(_ sender: Any) {
        let title = tripNameTextField.text!
        let details = descriptionTextView.text!
        let trip = Trip(title: title, details: details)
        tripsService.createTrip(trip, callback: {_ in 
            
        })
    }
    
    @IBAction func back(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }



}
