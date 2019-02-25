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
    private let userService = Services.shared.getUserService()
    private let currentLocationService = Services.shared.getCurrentLocationService()
    private let googleMapsService = Services.shared.getGoogleMapsService()

    @IBOutlet weak var mapView: LightuponGMSMapView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var sceneImage: UIImageView!
    @IBOutlet weak var captionTextField: UITextView!
    @IBOutlet weak var topBar: UIView!
    @IBOutlet weak var sceneAddressLabel: UILabel!
    @IBOutlet weak var sceneNameTextField: UITextField!
    @IBOutlet weak var locationSection: UIView!
    @IBOutlet weak var shareButton: UIButton!
    
    var captionTextFieldDirty = false
    var activeField: UITextField!
    var currentScene: Scene!
    var sceneNameFieldActive = false
    var locationSectionY: CGFloat!
    var locationPickerOpen = false
    var currentAddress: Address?
    var captionValid = false
    var addressValid = false
    var post = Post(caption: "")
    var mapDragged = false
    
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
        
        captionTextField.delegate = self
        
        locationSectionY = locationSection.frame.origin.y
        
        shareButton.isEnabled = false
        shareButton.setTitleColor(.mediumGrey, for: .disabled)
        
        UITextField.appearance().tintColor = .basePurple
        captionTextField.tintColor = .basePurple
        
        view.bringSubview(toFront: mapView)
        view.bringSubview(toFront: locationSection)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)

    }
    
    func keyboardWillShow(notification:NSNotification) {
        let userInfo:NSDictionary = notification.userInfo! as NSDictionary
        let keyboardFrame:NSValue = userInfo.value(forKey: UIKeyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.cgRectValue
        keyboardHeight = keyboardRectangle.height
    }
    
    @IBAction func share(_ sender: Any) {
        post.name = sceneNameTextField.text!
        post.caption = captionTextField.text
        tellUserHeOrSheIsJustSwell()
        postService.post(post:post)
    }
    
    func setShareButtonEnabledness() {
        let buttonEnabled = captionValid && addressValid
        shareButton.isEnabled = buttonEnabled
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

    func submitLocationPick() {
        post.name = sceneNameTextField.text!
        if let address: Address = currentAddress {
            post.address = address
        }
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

    
    func getCurrentLocation() {
        googleMapsService.getAddress(
            lat: currentLocationService.latitude,
            lon: currentLocationService.longitude,
            callback: self.onCurrentLocationGotten
        )
    }

    
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
            x: mapView.frame.width / 2,
            y: mapView.frame.height / 2 + 20,
            width: 40,
            height: 40
        )
        marker.makeCircle()
    }
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        if mapDragged == true {
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
        addressValid = true
    }
    
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        mapDragged = true
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
        captionValid = proposedText.count > 2
        let proposedTextValidity = proposedText.count < 156
        setShareButtonEnabledness()
        
        return proposedTextValidity
    }
    
    func makeKeyboardLeave() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        
        view.addGestureRecognizer(tap)
    }
    
    @IBAction func changeLocation(_ sender: Any) {}
}
