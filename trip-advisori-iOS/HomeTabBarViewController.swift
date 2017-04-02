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

class HomeTabBarViewController: UITabBarController, UITabBarControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CameraOverlayDelegate {
    fileprivate let userService = Services.shared.getUserService()
    fileprivate let postService = Services.shared.getPostService()
    
    var profileTabBarItem: UIImageView!
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
        
        styleTabBar()
        addMainButton()
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
        
        
        Alamofire.request(userService.currentUser.profilePictureURL!, method: .get, parameters: nil).responseJSON { response in
            let image = UIImage(data: response.data!)
            let profileItem = self.tabBar.items?.last
            let resizeImage = Toucan(image: image!).resize(profileItem!.image!.size, fitMode: Toucan.Resize.FitMode.scale).maskWithEllipse().image.withRenderingMode(.alwaysOriginal)
            let selectedImage = Toucan(image: image!).resize(profileItem!.image!.size, fitMode: Toucan.Resize.FitMode.scale).maskWithEllipse(borderWidth: 3, borderColor: UIColor.white).resize(profileItem!.image!.size, fitMode: Toucan.Resize.FitMode.scale).maskWithEllipse(borderWidth: 2, borderColor: UIColor.basePurple).image.withRenderingMode(.alwaysOriginal)
            profileItem?.image = resizeImage
            profileItem?.selectedImage = selectedImage
        }
    }
    
    func addMainButton() {
        let button: UIButton = UIButton(type: .custom)
        button.frame = CGRect(x: view.frame.width / 2 - 30, y: view.frame.height - 70, width: 60, height: 60)
        button.center = CGPoint(x:view.center.x , y: button.center.y)
        button.backgroundColor = UIColor.white
        button.addTarget(self, action: #selector(openCameraButton), for: .touchUpInside)
        button.layer.borderColor = UIColor.basePurple.cgColor
        button.layer.borderWidth = 3.0
        button.makeCircle()
        view.addSubview(button)
    }
    
    func onPhotoConfirmed() {
        dismiss(animated: true, completion: nil)
        performSegue(withIdentifier: "TabBarToSceneForm", sender: nil)
    }
    
    override var shouldAutorotate : Bool {
        return false
    }
    
    func openCameraButton(sender: AnyObject) {
        
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
                mapController.delegate = vc
            }
            
            if let tableController = controller as? FeedViewController {
                tableController.delegate = vc
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
