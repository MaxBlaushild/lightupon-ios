//
//  CameraOverlay.swift
//  Lightupon
//
//  Created by Blaushild, Max on 2/20/17.
//  Copyright © 2017 Blaushild, Max. All rights reserved.
//

import UIKit

protocol CameraOverlayDelegate {
    func onCancelPressed() -> Void
    func onPhotoConfirmed() -> Void
}

enum CameraStates {
    case normal, pending
}

let cameraButtonDiameter: CGFloat = 75.00

class CameraOverlay: UIView, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var cameraSwitchButton: UIButton!
    @IBOutlet weak var photoGalleryButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    
    var delegate: CameraOverlayDelegate!
    var imagePicker: UIImagePickerController!
    var photoButton: UIButton!
    var state: CameraStates = .normal
    var imagePreview: UIImageView!
    var screenshot: UIImage!
    
    func takePicture() {
        imagePicker.takePicture()
    }
    
    @IBAction func reset(_ sender: Any) {
        PickedImage.shared = nil
        setNormalState()
        removeImagePreview()
    }
    @IBAction func cameraSwitch(_ sender: Any) {
        imagePicker.cameraDevice = imagePicker.cameraDevice == .front ? .rear : .front
    }
    
    @objc(imagePickerController:didFinishPickingMediaWithInfo:) func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        PickedImage.shared = info[UIImagePickerControllerOriginalImage] as? UIImage
        imagePicker.sourceType = .camera
        setPendingState()
        setImagePreview()
    }
    
    func setImagePreview() {
        imagePreview = UIImageView(image: PickedImage.shared)
        imagePreview.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height / 4 * 3)
        let screenSize:CGSize = UIScreen.main.bounds.size
        let ratio:CGFloat = 4.0 / 3.0
        let cameraHeight:CGFloat = screenSize.width * ratio
        let scale:CGFloat = screenSize.height / cameraHeight
        
        imagePreview.transform = CGAffineTransform(translationX: 0, y: (screenSize.height - cameraHeight) / 2.0)
        imagePreview.transform = imagePreview.transform.scaledBy(x: scale, y: scale)
        insertSubview(imagePreview, belowSubview: photoButton)
        bringSubview(toFront: resetButton)
    }
    
    func configureImagePicker() {
        imagePicker.sourceType = UIImagePickerControllerSourceType.camera
        imagePicker.cameraOverlayView = self
        imagePicker.allowsEditing = false
        imagePicker.showsCameraControls = false
        let screenSize:CGSize = UIScreen.main.bounds.size
        
        let ratio:CGFloat = 4.0 / 3.0
        let cameraHeight:CGFloat = screenSize.width * ratio
        let scale:CGFloat = screenSize.height / cameraHeight
        
        imagePicker.cameraViewTransform = CGAffineTransform(translationX: 0, y: (screenSize.height - cameraHeight) / 2.0)
        imagePicker.cameraViewTransform = imagePicker.cameraViewTransform.scaledBy(x: scale, y: scale)
    }
    
    func removeImagePreview() {
        imagePreview.removeFromSuperview()
        imagePreview = nil
    }
    
    func setPendingState() {
        state = .pending
        photoButton.backgroundColor = UIColor.white
        photoButton.setImage(UIImage(named: "nextArrow"), for: .normal)
        cameraSwitchButton.isHidden = true
        photoGalleryButton.isHidden = true
        backButton.isHidden = true
        resetButton.isHidden = false
        photoButton.removeTarget(nil, action: nil, for: .allEvents)
        photoButton.addTarget(self, action: #selector(confirm), for: .touchUpInside)
    }
    
    func setNormalState() {
        state = .pending
        cameraSwitchButton.isHidden = false
        photoGalleryButton.isHidden = false
        backButton.isHidden = false
        resetButton.isHidden = true
        photoButton.backgroundColor = UIColor.clear
        photoButton.setImage(nil, for: .normal)
        photoButton.removeTarget(nil, action: nil, for: .allEvents)
        photoButton.addTarget(self, action: #selector(takePicture), for: .touchUpInside)
    }

    @IBAction func cancel(_ sender: Any) {
        if delegate != nil {
            delegate?.onCancelPressed()
        }
    }
    
    func confirm() {
        delegate.onPhotoConfirmed()
    }
    
    @IBAction func photoGallery(_ sender: Any) {
        imagePicker.sourceType = .photoLibrary
    }
    
    func initialize(_ _delegate: CameraOverlayDelegate, picker: UIImagePickerController) {
        delegate = _delegate
        imagePicker = picker
        configureImagePicker()
        imagePicker.delegate = self
        backButton.setImageTint(color: UIColor.white)
        addPhotoButton()
    }
    
    func addPhotoButton() {
        photoButton = UIButton(type: .custom)
        photoButton.frame = CGRect(
            x: center.x - cameraButtonDiameter / 2,
            y: photoGalleryButton.center.y - cameraButtonDiameter / 2,
            width: cameraButtonDiameter,
            height: cameraButtonDiameter)
        photoButton.layer.cornerRadius = 0.5 * photoButton.bounds.size.width
        photoButton.clipsToBounds = true
        photoButton.layer.borderColor = UIColor.white.cgColor
        photoButton.layer.borderWidth = 5.0
        photoButton.addTarget(self, action: #selector(takePicture), for: .touchUpInside)
        addSubview(photoButton)
    }

}
