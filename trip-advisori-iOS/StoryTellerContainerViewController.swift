//
//  StoryTellerContainerViewController.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 7/29/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//

import UIKit

private let centerPanelExpandedOffset: CGFloat = 60

private extension UIStoryboard {
    class func mainStoryboard() -> UIStoryboard { return UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()) }
    
    class func menuViewController() -> StoryTellerMenuViewController? {
        return mainStoryboard().instantiateViewControllerWithIdentifier("StoryTellerMenuViewController") as? StoryTellerMenuViewController
    }
    
    class func storyTellerViewController() -> StoryTellerViewController? {
        return mainStoryboard().instantiateViewControllerWithIdentifier("StoryTellerViewController") as? StoryTellerViewController
    }
}

class StoryTellerContainerViewController: UIViewController, StoryTellerViewControllerDelegate {
    var storyTellerViewController: StoryTellerViewController!
    var storyTellerNavigationController: UINavigationController!
    var menuOpen: Bool = false
    var menuViewController: StoryTellerMenuViewController!
    
    var partyState: PartyState!
    var currentParty: Party!

    override func viewDidLoad() {
        super.viewDidLoad()
        storyTellerViewController = UIStoryboard.storyTellerViewController()

        storyTellerViewController.partyState = partyState
        storyTellerViewController.currentParty = currentParty
        storyTellerViewController.delegate = self
        
        view.addSubview(storyTellerViewController.view)
        addChildViewController(storyTellerViewController)
        
        storyTellerViewController.didMoveToParentViewController(self)

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
    
    func addChildMenuController(menuViewController: StoryTellerMenuViewController) {
        view.insertSubview(menuViewController.view, atIndex: 0)
        
        addChildViewController(menuViewController)
        menuViewController.didMoveToParentViewController(self)
    }
    
    func animateCenterPanelXPosition(targetPosition: CGFloat, completion: ((Bool) -> Void)! = nil) {
        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .CurveEaseInOut, animations: {
            self.storyTellerViewController.view.frame.origin.x = targetPosition
            }, completion: completion)
    }
    
    func animateRightPanel(shouldExpand: Bool) {
        if (shouldExpand) {
            animateCenterPanelXPosition(-CGRectGetWidth(storyTellerViewController.view.frame) + centerPanelExpandedOffset)
        } else {
            animateCenterPanelXPosition(0) { _ in
                self.menuViewController!.view.removeFromSuperview()
                self.menuViewController = nil;
            }
        }
    }
    
    func showShadowForCenterViewController(shouldShowShadow: Bool) {
        if (shouldShowShadow) {
            storyTellerViewController.view.layer.shadowOpacity = 0.8
        } else {
            storyTellerViewController.view.layer.shadowOpacity = 0.0
        }
    }
}
