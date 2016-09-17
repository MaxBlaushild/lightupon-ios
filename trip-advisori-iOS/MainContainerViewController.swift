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
    class func mainStoryboard() -> UIStoryboard { return UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()) }
    
    class func menuViewController() -> StoryTellerMenuViewController? {
        return mainStoryboard().instantiateViewControllerWithIdentifier("StoryTellerMenuViewController") as? StoryTellerMenuViewController
    }
    
    class func storyTellerViewController() -> StoryTellerViewController? {
        return mainStoryboard().instantiateViewControllerWithIdentifier("StoryTellerViewController") as? StoryTellerViewController
    }
    
    class func homeTabBarViewController() -> HomeTabBarViewController? {
        return mainStoryboard().instantiateViewControllerWithIdentifier("HomeTabBarViewController") as? HomeTabBarViewController
    }
}

class MainContainerViewController: UIViewController, MainViewControllerDelegate {
    private let _partyService: PartyService = Injector.sharedInjector.getPartyService()
    
    var storyTellerViewController: StoryTellerViewController!
    var homeTabBarViewController: HomeTabBarViewController!
    var menuOpen: Bool = false
    var menuViewController: StoryTellerMenuViewController!
    var shownViewController: UIViewController!
    
    var _party: Party!

    override func viewDidLoad() {
        super.viewDidLoad()
        getParty()
    }
    
    func onPartyRetrieved(party: Party) {
        _party = party
        
        if (userIsInParty()) {
            initStoryTeller()
        } else {
            initHomeTabBarViewController()
        }
    }
    
    func userIsInParty() -> Bool {
        return (_party.id != 0)
    }
    
    func getParty() {
        _partyService.getUsersParty(self.onPartyRetrieved)
    }
    
    func initStoryTeller() {
        storyTellerViewController = UIStoryboard.storyTellerViewController()
        storyTellerViewController.delegate = self
        showViewController(storyTellerViewController)
        storyTellerViewController.bindParty(_party)
    }
    
    func initHomeTabBarViewController() {
        homeTabBarViewController = UIStoryboard.homeTabBarViewController()
        homeTabBarViewController.assignDelegation(self)
        showViewController(homeTabBarViewController)
    }
    
    func showViewController(viewController: UIViewController) {
        view.addSubview(viewController.view)
        addChildViewController(viewController)
        shownViewController = viewController
        viewController.didMoveToParentViewController(self)
        self.view.splashView()
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
        
        if (userIsInParty()) {
            menuViewController.bindParty(_party)
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
            self.shownViewController.view.frame.origin.x = targetPosition
            }, completion: completion)
    }
    
    func animateRightPanel(shouldExpand: Bool) {
        if (shouldExpand) {
            animateCenterPanelXPosition(-CGRectGetWidth(shownViewController.view.frame) + centerPanelExpandedOffset)
        } else {
            animateCenterPanelXPosition(0) { _ in }
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
