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
    
    class func homeTabBarViewController() -> HomeTabBarViewController? {
        return mainStoryboard().instantiateViewControllerWithIdentifier("HomeTabBarViewController") as? HomeTabBarViewController
    }
}

protocol MainContainerViewControllerDelegate {
    func onResponseReceived(partyState: PartyState) -> Void
}

class MainContainerViewController: UIViewController, MainViewControllerDelegate, SocketServiceDelegate {
    private let partyService: PartyService = Injector.sharedInjector.getPartyService()
    private let socketService: SocketService = Injector.sharedInjector.getSocketService()
    
    var storyTellerViewController: StoryTellerViewController!
    var homeTabBarViewController: HomeTabBarViewController!
    var menuOpen: Bool = false
    var menuViewController: StoryTellerMenuViewController!
    var shownViewController: SocketServiceDelegate!
    var socketResponseRecepients: [SocketServiceDelegate] = [SocketServiceDelegate]()
    
    var partyState: PartyState!
    var currentParty: Party!

    override func viewDidLoad() {
        super.viewDidLoad()
        getParty()
        socketService.delegate = self
    }
    
    func onPartyRetrieved(party: Party) {
        currentParty = party
        
        if (party.id == 0) {
            initHomeTabBarViewController()
        } else {
            initStoryTeller()
        }
    }
    
    func getParty() {
        partyService.getUsersParty(self.onPartyRetrieved)
    }
    
    func initStoryTeller() {
        storyTellerViewController = UIStoryboard.storyTellerViewController()
        
        storyTellerViewController.delegate = self
        shownViewController = storyTellerViewController
        
        view.addSubview(storyTellerViewController.view)
        addChildViewController(storyTellerViewController)
        socketResponseRecepients.append(storyTellerViewController)
        
        storyTellerViewController.didMoveToParentViewController(self)
    }
    
    func initHomeTabBarViewController() {
        homeTabBarViewController = UIStoryboard.homeTabBarViewController()
        
        homeTabBarViewController.assignDelegation(self)
        
        view.addSubview(homeTabBarViewController.view)
        addChildViewController(homeTabBarViewController)
        shownViewController = homeTabBarViewController
        socketResponseRecepients.append(homeTabBarViewController)
        
        homeTabBarViewController.didMoveToParentViewController(self)
    }
    
    func segueToStoryTeller() {
        homeTabBarViewController.view.removeFromSuperview()
        initStoryTeller()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func onResponseReceived(_partyState_: PartyState) {
        if let _ = shownViewController as? HomeTabBarViewController {
            if (self.partyState == nil) {
                segueToStoryTeller()
            }
        }

        for vc in socketResponseRecepients {
            vc.onResponseReceived(_partyState_)
        }
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
            socketResponseRecepients.append(menuViewController)
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
            let vc = self.shownViewController as! UIViewController
            vc.view.frame.origin.x = targetPosition
            }, completion: completion)
    }
    
    func animateRightPanel(shouldExpand: Bool) {
        if (shouldExpand) {
            let vc = shownViewController as! UIViewController
            animateCenterPanelXPosition(-CGRectGetWidth(vc.view.frame) + centerPanelExpandedOffset)
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
