//
//  HomeTabBarViewController.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 2/1/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//

import UIKit
import Alamofire
import Toucan

class HomeTabBarViewController: UITabBarController,
                                UITabBarControllerDelegate,
                                UIImagePickerControllerDelegate,
                                UINavigationControllerDelegate,
                                CameraOverlayDelegate {
    
    private let userService = Services.shared.getUserService()
    private let postService = Services.shared.getPostService()
    private let partyService = Services.shared.getPartyService()
    
    var profileTabBarItem: UIImageView!
    var mainButton: UIButton!
    let imagePicker = UIImagePickerController()
    
    var mainButtonAction:(() -> Void)!
    
    var tripId: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
        
        styleTabBar()
        addMainButton()
        
        mainButtonAction = openCamera
        
        NotificationCenter.default.addObserver(self, selector: #selector(mainActionToOpenCamera), name: partyService.partyChangeNotificationName, object: nil)
    }
    
    func styleTabBar() {
        UITabBar.appearance().barTintColor = UIColor.white
        UITabBar.appearance().tintColor = UIColor.basePurple
        tabBar.unselectedItemTintColor = UIColor.iconGrey
        UITabBar.appearance().layer.borderWidth = 0.0
        UITabBar.appearance().clipsToBounds = true
        for (index, tabBarItem) in tabBar.items!.enumerated() {
            if index != 3 {
                tabBarItem.selectedImage = tabBarItem.selectedImage?.withRenderingMode(.alwaysOriginal)
                tabBarItem.image = tabBarItem.image?.withRenderingMode(.alwaysOriginal)
            }

            tabBarItem.title = ""
            tabBarItem.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0)
        }
        
        
        Alamofire.request(userService.currentUser.profilePictureURL, method: .get, parameters: nil).responseJSON { response in
            let image = UIImage(data: response.data!)
            let profileItem = self.tabBar.items?.last
            let resizeImage = Toucan(image: image!).resize(profileItem!.image!.size, fitMode: Toucan.Resize.FitMode.scale).maskWithEllipse().image.withRenderingMode(.alwaysOriginal)
            let selectedImage = Toucan(image: image!).resize(profileItem!.image!.size, fitMode: Toucan.Resize.FitMode.scale).maskWithEllipse(borderWidth: 3, borderColor: UIColor.white).resize(profileItem!.image!.size, fitMode: Toucan.Resize.FitMode.scale).maskWithEllipse(borderWidth: 2, borderColor: UIColor.basePurple).image.withRenderingMode(.alwaysOriginal)
            profileItem?.image = resizeImage
            profileItem?.selectedImage = selectedImage
        }
    }
    
    func addMainButton() {
        mainButton = UIButton(type: .custom)
        mainButton.frame = CGRect(x: view.frame.width / 2 - 30, y: view.frame.height - 70, width: 60, height: 60)
        mainButton.center = CGPoint(x:view.center.x , y: mainButton.center.y)
        mainButton.backgroundColor = UIColor.white
        mainButton.addTarget(self, action: #selector(performMainAction), for: .touchUpInside)
        mainButton.layer.borderColor = UIColor.basePurple.cgColor
        mainButton.layer.borderWidth = 3.0
        mainButton.makeCircle()
        view.addSubview(mainButton)
    }
    
    func onPhotoConfirmed() {
        dismiss(animated: true, completion: nil)
        performSegue(withIdentifier: "TabBarToSceneForm", sender: nil)
    }
    
    override var shouldAutorotate : Bool {
        return false
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if let detailsVCDelegate = tabBarController.selectedViewController as? TripDetailsViewControllerDelegate {
            if detailsVCDelegate.canStartParty() {
                mainActionToStartParty(tId: detailsVCDelegate.tripDetailsViewController.tripId)
            } else {
                mainActionToOpenCamera()
            }
        }
    }
    
    func mainActionToOpenCamera() {
        tripId = nil
        mainButtonAction = openCamera
        mainButton.backgroundColor = .white
    }
    
    func mainActionToStartParty(tId: Int) {
        tripId = tId
        mainButtonAction = startParty
        mainButton.backgroundColor = .basePurple
    }
    
    func performMainAction() {
        mainButtonAction()
    }
    
    func startParty() {
        if let id = tripId {
            partyService.createParty(id, callback: {
                self.selectedIndex = 0
            })
        }
    }
    
    func openCamera() {
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            let overlay = CameraOverlay.fromNib("CameraOverlay")
            overlay.initialize(self, picker: imagePicker)
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func onCancelPressed() {
        dismiss(animated: true, completion: nil)
    }

    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if let _ = viewController as? NotSelectingViewController {
            return false
        }
        return true
    }
    
    
    func maskRoundedImage(image: UIImage, radius: Float) -> UIImage {
        let imageView: UIImageView = UIImageView(image: image)
        var layer: CALayer = CALayer()
        layer = imageView.layer
        
        layer.masksToBounds = true
        layer.cornerRadius = CGFloat(radius)
        
        UIGraphicsBeginImageContext(imageView.bounds.size)
        layer.render(in: UIGraphicsGetCurrentContext()!)
        let roundedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return roundedImage!
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
    
    func assignDelegation(_ vc: MainContainerViewController) {
        for controller in viewControllers! {
            
            if let mapController = controller as? MapViewController {
            }
            
            if let feedController = controller as? FeedViewController {
                feedController.delegate = vc
                feedController.onViewOpened = mainActionToStartParty
                feedController.onViewClosed = mainActionToOpenCamera
            }
            
            if let profileController = controller as? ProfileViewController {
                profileController.initProfile()
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
