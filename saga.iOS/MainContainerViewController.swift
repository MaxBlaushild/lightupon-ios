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
    
    class func menuViewController() -> QuestLogViewController? {
        return mainStoryboard().instantiateViewController(withIdentifier: "QuestLogViewController") as? QuestLogViewController
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
    var menuViewController: QuestLogViewController!
    var loadingAnimation: LoadingAnimationView!

    override func viewDidLoad() {
        super.viewDidLoad()
        initMapViewController()
    }
    
    func initMapViewController() {
        mapViewController = UIStoryboard.mapViewController()
        mapViewController.delegate = self
        view.addSubview(mapViewController.view)
        addChildViewController(mapViewController)
        mapViewController.didMove(toParentViewController: self)
    }
    
    func showLoading() {
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
    
    func addChildMenuController(_ menuViewController: QuestLogViewController) {
        view.insertSubview(menuViewController.view, at: 0)
        addChildViewController(menuViewController)
        menuViewController.didMove(toParentViewController: self)
    }
    
    func animateCenterPanelXPosition(_ targetPosition: CGFloat, completion: ((Bool) -> Void)! = nil) {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: UIViewAnimationOptions(), animations: {
            self.mapViewController.view.frame.origin.x = targetPosition
            }, completion: completion)
    }
    
    func animateRightPanel(_ shouldExpand: Bool) {
        if (shouldExpand) {
            animateCenterPanelXPosition(-mapViewController.view.frame.width + centerPanelExpandedOffset)
        } else {
            animateCenterPanelXPosition(0) { _ in }
        }
    }

}
