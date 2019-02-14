//
//  StoryTellerContainerViewController.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 7/29/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//

import UIKit
import CBZSplashView

private let centerPanelExpandedOffset: CGFloat = 60

private extension UIStoryboard {
    class func mainStoryboard() -> UIStoryboard { return UIStoryboard(name: "Main", bundle: Bundle.main) }
    
    class func menuViewController() -> StoryTellerMenuViewController? {
        return mainStoryboard().instantiateViewController(withIdentifier: "StoryTellerMenuViewController") as? StoryTellerMenuViewController
    }

    class func homeTabBarViewController() -> HomeTabBarViewController? {
        return mainStoryboard().instantiateViewController(withIdentifier: "HomeTabBarViewController") as? HomeTabBarViewController
    }
    
    class func mapViewController() -> MapViewController? {
        return mainStoryboard().instantiateViewController(withIdentifier: "MapViewController") as? MapViewController
    }
}

protocol MainViewControllerDelegate {
    func toggleRightPanel()
}

class MainContainerViewController: UIViewController, MainViewControllerDelegate, LoadingAnimationViewDelegate {
    var mapViewController: MapViewController!
    var menuOpen: Bool = false
    var menuViewController: StoryTellerMenuViewController!
    var shownViewController: UIViewController!
    var loadingAnimation: LoadingAnimationView!

    override func viewDidLoad() {
        super.viewDidLoad()
        initMapViewController()
    }
    
    func initMapViewController() {
        mapViewController = UIStoryboard.mapViewController()
        mapViewController.delegate = self
        showViewController(mapViewController)
    }
    
    func showViewController(_ viewController: UIViewController) {
        view.addSubview(viewController.view)
        addChildViewController(viewController)
        shownViewController = viewController
        viewController.didMove(toParentViewController: self)
        loadingAnimation = LoadingAnimationView.fromNib("LoadingAnimationView")
        loadingAnimation.initialize(parentView: self)
        view.addSubview(loadingAnimation)
        loadingAnimation.animate()
    }
    
    func dismissLoadingView() {
        loadingAnimation.removeFromSuperview()
        loadingAnimation = nil
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func toggleRightPanel() {
        let menuShouldOpen = !menuOpen
        
        if (menuShouldOpen) {
            addRightPanelViewController()
        }
        
        animateRightPanel(menuShouldOpen)
        menuOpen = menuShouldOpen
    }
    
    func addRightPanelViewController() {
        if (menuViewController == nil) {
            menuViewController = UIStoryboard.menuViewController()
            addChildMenuController(menuViewController!)
        }
    }
    
    func addChildMenuController(_ menuViewController: StoryTellerMenuViewController) {
        view.insertSubview(menuViewController.view, at: 0)
        addChildViewController(menuViewController)
        menuViewController.didMove(toParentViewController: self)
    }
    
    func animateCenterPanelXPosition(_ targetPosition: CGFloat, completion: ((Bool) -> Void)! = nil) {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: UIViewAnimationOptions(), animations: {
            self.shownViewController.view.frame.origin.x = targetPosition
            }, completion: completion)
    }
    
    func animateRightPanel(_ shouldExpand: Bool) {
        if (shouldExpand) {
            animateCenterPanelXPosition(-shownViewController.view.frame.width + centerPanelExpandedOffset)
        } else {
            animateCenterPanelXPosition(0) { _ in }
        }
    }

}
