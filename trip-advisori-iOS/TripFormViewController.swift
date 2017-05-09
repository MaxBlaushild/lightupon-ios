//
//  TripFormViewController.swift
//  Lightupon
//
//  Created by Blaushild, Max on 5/4/17.
//  Copyright © 2017 Blaushild, Max. All rights reserved.
//

import UIKit

class TripFormViewController: TripModalPresentingViewController {
    
    private let postService = Services.shared.getPostService()
    private let tripsService = Services.shared.getTripsService()
    private let userService = Services.shared.getUserService()

    @IBOutlet weak var scenePreviewImageView: UIImageView!
    @IBOutlet weak var sceneAddressLabel: UILabel!
    @IBOutlet weak var sceneNameLabel: UILabel!
    @IBOutlet weak var scenePreviewSection: UIView!
    
    var currentScene: Scene!
    var currentCard: Card!
    var trips: [Trip]!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        sceneAddressLabel.text = "\(currentScene.streetNumber) \(currentScene.route)"
        sceneNameLabel.text = currentScene.name
        
        scenePreviewImageView.image = PickedImage.shared
        scenePreviewImageView.makeCircle()
        
        scenePreviewSection.layer.addBorder(edge: .top, color: .lightGray, thickness: 1)
        scenePreviewSection.layer.addBorder(edge: .bottom, color: .lightGray, thickness: 1)
        
        let border = CALayer()
        border.frame = CGRect(
            x: 0,
            y: scenePreviewSection.frame.size.height,
            width: 95,
            height: 2
        )
        border.backgroundColor = UIColor.black.cgColor
        scenePreviewSection.layer.addSublayer(border)
        
        tripsService.getUsersTrips(userService.currentUser.id, callback: { trips in
            self.trips = trips
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func share(_ sender: Any) {
        tellUserHeOrSheIsJustSwell()
        postService.post(card: currentCard, scene: currentScene)
    }
    
    func tellUserHeOrSheIsJustSwell() {
        addBlurView()
        addPostConfirmationView()
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
            self.dismiss(animated: true, completion: nil)
        })
    }
    
    func addPostConfirmationView() {
        let postConfirmationView = PostConfirmationView.fromNib("PostConfirmationView")
        view.addSubview(postConfirmationView)
    }

}
