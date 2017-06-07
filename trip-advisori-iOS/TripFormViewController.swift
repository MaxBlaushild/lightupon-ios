//
//  TripFormViewController.swift
//  Lightupon
//
//  Created by Blaushild, Max on 5/4/17.
//  Copyright © 2017 Blaushild, Max. All rights reserved.
//

import UIKit

class TripFormViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, CreateTripViewControllerDelegate {
    
    private let postService = Services.shared.getPostService()
    private let tripsService = Services.shared.getTripsService()
    private let userService = Services.shared.getUserService()

    @IBOutlet weak var scenePreviewImageView: UIImageView!
    @IBOutlet weak var sceneAddressLabel: UILabel!
    @IBOutlet weak var sceneNameLabel: UILabel!
    @IBOutlet weak var scenePreviewSection: UIView!
    @IBOutlet weak var tripCollectionView: UICollectionView!
    @IBOutlet weak var backButton: UIButton!
    
    
    var currentScene: Scene!
    var currentCard: Card!
    var blurView: UIVisualEffectView!
    var trips: [Trip] = [Trip]()
    var scenes: [Scene] = [Scene]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tripCollectionView.delegate = self
        tripCollectionView.dataSource = self
        
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
            self.trips = trips.filter({ trip in
                return !trip.title.isEmpty
            })
            
            self.tripCollectionView.reloadData()
        })
        
        let origImage = UIImage(named: "left_chevron")
        let tintedImage = origImage?.withRenderingMode(.alwaysTemplate)
        backButton.setImage(tintedImage, for: .normal)
        backButton.tintColor = .black
    }

    @IBAction func makeNewTrip(_ sender: Any) {
       performSegue(withIdentifier: "TripFormToCreateTrip", sender: self)
    }
    
    @IBAction func alsoMakeNewTrip(_ sender: Any) {
        performSegue(withIdentifier: "TripFormToCreateTrip", sender: self)
    }
    
    @IBAction func goBack(_ sender: Any) {
        dismiss(animated: false, completion: {})
    }
    
    func onTripCreated(_ trip: Trip) {
        trips.insert(trip, at: 0)
        tripCollectionView.reloadData()
        tripCollectionView.performBatchUpdates({}, completion: { _ in
            let selectedIndex = IndexPath(row: 0, section: 0)
            self.tripCollectionView.selectItem(at: selectedIndex, animated: false, scrollPosition: .top)
            self.collectionView(self.tripCollectionView, didSelectItemAt: selectedIndex)
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let trip = trips[(indexPath as NSIndexPath).row]
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TripCollectionViewCell", for: indexPath) as! TripCollectionViewCell
            cell.tripNameLabel.text = trip.title
            cell.numberOfScenesLabel.text = "\(trip.scenes.count) scenes"
            cell.tag = trip.id
            return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return trips.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath){
        tripCollectionView.visibleCells.forEach({ cell in
            let tripCell = cell as! TripCollectionViewCell
            tripCell.backgroundColor = .white
            tripCell.tripNameLabel.textColor = .basePurple
            tripCell.numberOfScenesLabel.textColor = .darkGrey
        })
        
        let selectedTripCell = tripCollectionView.cellForItem(at: indexPath) as! TripCollectionViewCell
        
        selectedTripCell.backgroundColor = .basePurple
        selectedTripCell.tripNameLabel.textColor = .white
        selectedTripCell.numberOfScenesLabel.textColor = .white
    }
    
    @IBAction func share(_ sender: Any) {
        var selectedTripId: Int?
        
        if let selectedCellPaths = tripCollectionView.indexPathsForSelectedItems {
            if selectedCellPaths.count > 0 {
                let selectedCellIndex = selectedCellPaths[0]
                let selectedCell = tripCollectionView.cellForItem(at: selectedCellIndex)
                if let tag = selectedCell?.tag {
                    selectedTripId = tag
                }
            }
        }
        
        
        tellUserHeOrSheIsJustSwell()
        postService.post(card: currentCard, scene: currentScene, tripID: selectedTripId, sceneID: nil)
    }
    
    func addBlurView() {
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.light)
        blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = view.bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(blurView)
    }
    
    func tellUserHeOrSheIsJustSwell() {
        addBlurView()
        addPostConfirmationView()
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
            self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
        })
    }
    
    func addPostConfirmationView() {
        let postConfirmationView = PostConfirmationView.fromNib("PostConfirmationView")
        view.addSubview(postConfirmationView)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? CreateTripViewController {
            destinationVC.delegate = self
        }
    }

}
