//
//  SceneFormViewController.swift
//  Lightupon
//
//  Created by Blaushild, Max on 2/7/17.
//  Copyright © 2017 Blaushild, Max. All rights reserved.
//

import UIKit
import GoogleMaps

class SceneFormViewController: TripModalPresentingViewController, UIGestureRecognizerDelegate, GMSMapViewDelegate, UITextFieldDelegate, UITextViewDelegate {
    
    private let postService = Services.shared.getPostService()
    private let tripService = Services.shared.getTripsService()
    private let userService = Services.shared.getUserService()
    private let currentLocationService = Services.shared.getCurrentLocationService()
    private let googleMapsService = Services.shared.getGoogleMapsService()
    private let twitterService = Services.shared.getTwitterService()

    @IBOutlet weak var mapView: LightuponGMSMapView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var sceneImage: UIImageView!
    @IBOutlet weak var captionTextField: UITextView!
    @IBOutlet weak var topBar: UIView!
    @IBOutlet weak var sceneAddressLabel: UILabel!
    @IBOutlet weak var sceneNameTextField: UITextField!
    @IBOutlet weak var locationSection: UIView!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var twitterButton: UIButton!
    
    var captionTextFieldDirty = false
    var activeField: UITextField!
    var currentScene: Scene!
    var sceneNameFieldActive = false
    var mapDragged = false
    var locationSectionY: CGFloat!
    var cancelButton: UIButton!
    var doneButton: UIButton!
    var locationPickerOpen = false
    var currentAddress: Address?
    var captionValid = false
    var addressValid = false
    var shareOnFacebook = false
    var shareOnTwitter = false
    var post = Post(caption: "")
    
    var keyboardHeight: CGFloat?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        sceneImage.image = PickedImage.shared
        postService.uploadPicture(image: PickedImage.shared)
        makeKeyboardLeave()
        getCurrentLocation()
        setDelegation()
        addMiddleIconToMap()
        tintBackButton()
        watchForLocationSectionTouch()
        addDoneButton()
        
        captionTextField.delegate = self
        
        locationSectionY = locationSection.frame.origin.y
        
        shareButton.isEnabled = false
        shareButton.setTitleColor(.mediumGrey, for: .disabled)
        
        UITextField.appearance().tintColor = .basePurple
        captionTextField.tintColor = .basePurple
        
        view.bringSubview(toFront: mapView)
        view.bringSubview(toFront: locationSection)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)

    }
    
    func keyboardWillShow(notification:NSNotification) {
        let userInfo:NSDictionary = notification.userInfo! as NSDictionary
        let keyboardFrame:NSValue = userInfo.value(forKey: UIKeyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.cgRectValue
        keyboardHeight = keyboardRectangle.height
        centerTextView()
    }
    
    func keyboardWillHide() {
        centerView()
    }
    
    @IBAction func share(_ sender: Any) {
        post.name = sceneNameTextField.text!
        post.caption = captionTextField.text
        post.shareOnFacebook = shareOnFacebook
        post.shareOnTwitter = shareOnTwitter
        tellUserHeOrSheIsJustSwell()
        postService.post(post:post)
    }
    
    @IBAction func toggleShareToFacebook(_ sender: Any) {
        shareOnFacebook = !shareOnFacebook
        let icon = shareOnFacebook ? UIImage(named: "facebook-filled") : UIImage(named: "facebook-unfilled")
        facebookButton.setImage(icon, for: .normal)
    }
    
    @IBAction func toggleShareToTwitter(_ sender: Any) {
        shareOnTwitter = !shareOnTwitter
        let icon = shareOnTwitter ? UIImage(named: "twitter-filled") : UIImage(named: "twitter-unfilled")
        twitterButton.setImage(icon, for: .normal)
        
        if shareOnTwitter {
            twitterService.logIn {}
        }
    }
    
    func watchForLocationSectionTouch() {
        let gesture = UITapGestureRecognizer(target: self, action:  #selector(setLocationPickingState))
        locationSection.addGestureRecognizer(gesture)
    }
    
    func setShareButtonEnabledness() {
        let buttonEnabled = captionValid && addressValid
        shareButton.isEnabled = buttonEnabled
    }
    
    func setLocationPickingState() {
        if !locationPickerOpen {
            locationPickerOpen = true
            doneButton.isHidden = false
            UIView.animate(withDuration: 0.5, animations: {
                self.locationSection.frame.origin.y = UIApplication.shared.statusBarFrame.height
                self.mapView.frame.origin.y = UIApplication.shared.statusBarFrame.height
            }, completion: { _ in
                self.addCancelButton()
            })
        }
    }
    
    func tellUserHeOrSheIsJustSwell() {
        addBlurView()
        addPostConfirmationView()
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
            self.dismiss(animated: true, completion: nil)
        })
    }
    
    override func addBlurView() {
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.light)
        blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = view.bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(blurView)
    }
    
    func addPostConfirmationView() {
        let postConfirmationView = PostConfirmationView.fromNib("PostConfirmationView")
        postConfirmationView.frame = UIScreen.main.bounds
        view.addSubview(postConfirmationView)
    }
    
    func addCancelButton() {
        let origImage = UIImage(named: "mainCancel")
        let tintedImage = origImage?.withRenderingMode(.alwaysTemplate)
        cancelButton = UIButton()
        cancelButton.frame = CGRect(x: view.frame.width - 60, y: self.locationSection.frame.height / 2 - 20, width: 40, height: 40)
        cancelButton.addTarget(self, action: #selector(cancelLocationPick), for: .touchUpInside)
        locationSection.addSubview(cancelButton)
        cancelButton.setImage(tintedImage, for: .normal)
        cancelButton.tintColor = .darkGrey
    }
    
    func addDoneButton() {
        doneButton = UIButton()
        doneButton.frame = CGRect(x: 40, y: self.mapView.frame.height - 60, width: self.view.frame.width - 80, height: 40)
        doneButton.backgroundColor = UIColor.basePurple
        doneButton.titleLabel?.font = UIFont(name: "GothamRounded-Book", size: 20)
        doneButton.titleLabel?.textColor = UIColor.white
        doneButton.setTitle("DONE", for: .normal)
        
        doneButton.addTarget(self, action: #selector(submitLocationPick), for: .touchUpInside)
        mapView.addSubview(doneButton)
    }
    
    func submitLocationPick() {
        post.name = sceneNameTextField.text!
        if let address: Address = currentAddress {
            post.address = address
        }
        setNotLocationingPickingState()
    }
    
    func cancelLocationPick() {
        sceneNameTextField.text = post.neighborhood
        sceneAddressLabel.text = "\(post.streetNumber) \(post.route)"
        locationPickerOpen = false
        stopTheJitters()
        setNotLocationingPickingState()
    }
    
    func stopTheJitters() {
        view.layoutIfNeeded()
        mapView.layoutIfNeeded()
        sceneAddressLabel.layoutIfNeeded()
        sceneNameTextField.layoutIfNeeded()
        locationSection.frame.origin.y = UIApplication.shared.statusBarFrame.height
        mapView.frame.origin.y = UIApplication.shared.statusBarFrame.height
    }
    
    func setNotLocationingPickingState() {
        locationPickerOpen = false
        UIView.animate(withDuration: 0.5, animations: {
            self.locationSection.frame.origin.y = self.captionTextField.frame.maxY
            self.mapView.frame.origin.y = self.view.frame.height
        }, completion: { _ in
            self.cancelButton.removeFromSuperview()
        })
    }
    
    func setDelegation() {
        mapView.delegate = self
        captionTextField.delegate = self
        sceneNameTextField.delegate = self
    }
    
    func tintBackButton() {
        let origImage = UIImage(named: "left_chevron")
        let tintedImage = origImage?.withRenderingMode(.alwaysTemplate)
        backButton.setImage(tintedImage, for: .normal)
        backButton.tintColor = .black
    }
    
    @IBAction func goBack(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func updateTrip(_ sender: Any) {
        openTripModal()
    }
    
    override func onTripNameSaved(_ trip: Trip) {
        tripNameModal.removeFromSuperview()
        blurView.removeFromSuperview()
        tripExplanationLabel.removeFromSuperview()
    }
    
    func getCurrentLocation() {
        googleMapsService.getAddress(
            lat: currentLocationService.latitude,
            lon: currentLocationService.longitude,
            callback: self.onCurrentLocationGotten
        )
    }
    
//    func getActiveTrip() {
//        tripService.getActiveTrip(callback: self.setActiveTrip)
//    }
//
//    func setActiveTrip(trip: Trip) {
//        currentTrip = trip
//        if !trip.title.isEmpty {
//        }
//    }

    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeField = textField
        sceneNameFieldActive = (textField == sceneNameTextField)
    }
    
    func bindCurrentLocationToMap() {
        addMiddleIconToMap()
        let camera = GMSCameraPosition.camera(withLatitude: currentScene.latitude,
                                 longitude: currentScene.longitude,
                                 zoom: 18)
        mapView.camera = camera
    }
    
    func addMiddleIconToMap() {
        let marker = UIImageView(image: PickedImage.shared)
        mapView.addSubview(marker)
        marker.frame = CGRect(
            x: view.frame.width / 2 - 20,
            y: mapView.frame.height / 2 - 20,
            width: 40,
            height: 40
        )
        marker.makeCircle()
    }
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        if mapDragged == true && locationPickerOpen {
            mapDragged = false
            googleMapsService.getAddress(
                lat: mapView.camera.target.latitude,
                lon: mapView.camera.target.longitude,
                callback: self.bindAddress
            )
        }
    }
    
    func onCurrentLocationGotten(_ address: Address) {
        let currentLocation = GMSCameraPosition.camera(withLatitude: address.latitude!,
                                              longitude: address.longitude!,
                                              zoom: 18)
        mapView.camera = currentLocation
        post.address = address
        bindAddress(address)
    }
    
    func bindAddress(_ address: Address) {
        currentAddress = address
        sceneAddressLabel.text = "\(address.streetNumber!) \(address.route!)"
        sceneNameTextField.text = address.neighborhood
        stopTheJitters()
        doneButton.isHidden = false
        addressValid = true
    }
    
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        mapDragged = true
        doneButton.isHidden = true
    }
    
    func bindCurrentLocation() {
        currentScene.latitude = currentLocationService.latitude
        currentScene.longitude = currentLocationService.longitude
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func dismissKeyboard(sender: UITapGestureRecognizer) {
        sceneNameFieldActive = false
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true;
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if !captionTextFieldDirty {
            captionTextField.text = ""
            captionTextField.textColor = UIColor.black
            captionTextField.setFontSize(size: 22.0)
        }
        
        captionTextFieldDirty = true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        let proposedText = textView.text + text
        captionValid = proposedText.characters.count > 2
        let proposedTextValidity = proposedText.characters.count < 156
        setShareButtonEnabledness()
        
        return proposedTextValidity
    }
    
    func centerTextView() {
//        let keyHeight = keyboardHeight ?? 0.00
//        let centerYOfExposedView = (view.frame.height - keyHeight) / 2
//        let centerOfExposedView = CGPoint(x: view.center.x, y: centerYOfExposedView)
//        UIView.animate(withDuration: 0.25, animations: {
//            self.view.center = centerOfExposedView
//        })
    }
    
    func centerView() {
//        UIView.animate(withDuration: 0.25, animations: {
//            self.view.frame = UIScreen.main.bounds
//        })
    }
    
    func makeKeyboardLeave() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        
        view.addGestureRecognizer(tap)
    }
    
    @IBAction func changeLocation(_ sender: Any) {}
}
