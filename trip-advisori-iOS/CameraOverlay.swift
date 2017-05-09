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

enum PanDirection {
    case left, right
}

let cameraButtonDiameter: CGFloat = 75.00

class CameraOverlay: UIView, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    private let postService = Services.shared.getPostService()
    
    private let reuseIdentifier = "CardCollectionViewCell"

    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var cameraSwitchButton: UIButton!
    @IBOutlet weak var photoGalleryButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var cardCollectionView: UICollectionView!
    
    var delegate: CameraOverlayDelegate!
    var imagePicker: UIImagePickerController!
    var photoButton: UIButton!
    var state: CameraStates = .normal
    var imagePreview: UIImageView!
    var screenshot: UIImage!
    var suggestedScene: Scene?
    var panDirection: PanDirection!
    var currentCellIndex: Int!
    var nextCellIndex: Int!
    var cardPreviewExists: Bool!
    var cellXPositions: [CGFloat]!
    var focusedCell: CardCollectionViewCell!
    var whiteView: UIView!
    
    private var imagePicked = false
    
    
    func takePicture() {
        imagePicker.takePicture()
    }
    
    @IBAction func reset(_ sender: Any) {
        PickedImage.shared = nil
        setNormalState()
        
        if sceneInProgress() {
            removeCarousel()
        } else {
            removeImagePreview()
        }

    }
    @IBAction func cameraSwitch(_ sender: Any) {
        imagePicker.cameraDevice = imagePicker.cameraDevice == .front ? .rear : .front
    }
    
    @objc(imagePickerController:didFinishPickingMediaWithInfo:) func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        PickedImage.shared = info[UIImagePickerControllerOriginalImage] as? UIImage
        imagePicker.sourceType = .camera

        if let _ = suggestedScene {
            loadPreview()
        } else {
            self.imagePicked = true
        }
    }
    
    func loadPreview() {
        setPendingState()
        
        if sceneInProgress() {
            setCarousel()
        } else {
            setImagePreview()
        }

    }
    
    func sceneInProgress() -> Bool {
        var inProgress = false
        
        if let scene = suggestedScene {
            if scene.cards.count > 0 {
                inProgress = true
            }
        }
        
        return inProgress
    }
    
    @IBAction func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
        let translation = gestureRecognizer.translation(in: self)

        if gestureRecognizer.state == .began {
            cellXPositions = cardCollectionView.visibleCells.map({ cell in
                return cell.center.x
            })
        }
        
        if gestureRecognizer.state == .began || gestureRecognizer.state == .changed {
            panDirection = translation.x >= 0.0 ? .right : .left
            currentCellIndex = cardCollectionView.visibleCells.index(of: focusedCell)
            nextCellIndex = currentCellIndex! + (panDirection == .left ? 1 : -1)
            cardPreviewExists = cardCollectionView.visibleCells.indices.contains(nextCellIndex)
            let offset = cardPreviewExists! ? translation.x : translation.x / 1.75
            cardCollectionView.visibleCells.forEach({ cell in
                cell.center = CGPoint(x: cell.center.x - offset, y: focusedCell.center.y)
            })
            gestureRecognizer.setTranslation(CGPoint.zero, in: self)
        }
        
        if gestureRecognizer.state == .ended {
            let multiplier: CGFloat = panDirection == .left ? -1.0 : 1.0
            let offset = cardPreviewExists! ? (bounds.size.width - 50) * multiplier : 0.0
                
            UIView.animate(withDuration: 0.25, animations: {
                for (index, cell) in self.cardCollectionView.visibleCells.enumerated() {
                    cell.center = CGPoint(x: self.cellXPositions[index] - offset, y: cell.center.y)
                }
            }, completion: { _ in
                if self.cardPreviewExists! {
                    self.focusedCell = self.cardCollectionView.visibleCells[self.nextCellIndex] as! CardCollectionViewCell
                }
            
            })
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let card = suggestedScene?.cards[(indexPath as NSIndexPath).row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CardCollectionViewCell
        let gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        cell.addGestureRecognizer(gestureRecognizer)

        if card?.pending != nil {
            cell.previewImageView.image = PickedImage.shared
        } else {
            cell.previewImageView.imageFromUrl(card!.imageUrl, success: { img in
                cell.previewImageView.image = img
                cell.backgroundColor = .red
            })
        }

        cell.contentView.addShadow()
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let scene = suggestedScene {
            return scene.cards.count
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 17.50
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let kWhateverHeightYouWant = cardCollectionView.frame.height
        return CGSize(width: bounds.size.width - 70, height: CGFloat(kWhateverHeightYouWant))
    }
    
    func removeCarousel() {
        whiteView.removeFromSuperview()
        whiteView = nil
        cardCollectionView.isHidden = true
        photoButton.backgroundColor = UIColor.white
        photoButton.setImage(UIImage(named: "nextArrow"), for: .normal)
        photoButton.isHidden = false
        bringSubview(toFront: photoButton)
    }
    
    func setCarousel() {
        whiteView = UIView(frame: frame)
        whiteView.backgroundColor = .white
        addSubview(whiteView)
        bringSubview(toFront: whiteView)
        bringSubview(toFront: photoButton)
        bringSubview(toFront: resetButton)
        resetButton.setImageTint(color: .basePurple)
        photoButton.setImageTint(imageName: "nextArrow", color: .white)
        photoButton.backgroundColor = .basePurple
        photoButton.layer.borderWidth = 0.0
        cardCollectionView.isHidden = false
        bringSubview(toFront: cardCollectionView)
        let pendingCard = Card(pending: true)
        suggestedScene?.cards.append(pendingCard)
        suggestedScene?.cards = suggestedScene!.cards.reversed()
        cardCollectionView.isScrollEnabled = false
        cardCollectionView.reloadData()
        cardCollectionView.scrollToItem(at: IndexPath(row: suggestedScene!.cards.count - 1, section: 0), at: .right, animated: false)
        cardCollectionView.layoutIfNeeded()
        focusedCell = cardCollectionView.visibleCells.last as! CardCollectionViewCell!
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
        cardCollectionView.delegate = self
        cardCollectionView.dataSource = self
        backButton.setImageTint(color: UIColor.white)
        addPhotoButton()
        let nibName = UINib(nibName: "CardCollectionViewCell", bundle:nil)
        cardCollectionView.register(nibName, forCellWithReuseIdentifier: "CardCollectionViewCell")
        cardCollectionView.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        postService.getActiveScene(callback: { scene in
            self.suggestedScene = scene
            
            if self.imagePicked {
                self.loadPreview()
            }
        })
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
