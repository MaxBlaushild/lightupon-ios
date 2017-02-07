//
//  TripDetailsViewController.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 12/21/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//

import UIKit

protocol TripDetailsViewControllerDelegate {
    func onDismissed () -> Void
    func onSceneChanged (_ scene: Scene) -> Void
}

class TripDetailsViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate, ProfileViewCreator, ProfileViewDelegate {
    private let tripsService = Injector.sharedInjector.getTripsService()
    private var _tripId: Int!
    private var _trip: Trip!
    
    private var cardViewControllers: [CardViewController] = [CardViewController]()
    private var overlay:UIView!
    private var beltOverlay:BeltOverlayView!
    private var constellationPoints: [UIView] = [UIView]()
    private var currentIndex: Int = 0
    
    var profileView: ProfileView!
    var xBackButton:XBackButton!
    
    var tripDelegate: TripDetailsViewControllerDelegate?
    
    init(tripId: Int) {
        _tripId = tripId
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        getTrip()
        addBeltOverlay()
    }
    
    init(scene: Scene) {
        _tripId = scene.tripId!
        currentIndex = scene.sceneOrder! - 1
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        getTrip()
        addBeltOverlay()
        beltOverlay.bindView(scene: scene, owner: (scene.trip?.owner!)!, card: scene.cards[0])
    }
    
    init() {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        addBeltOverlay()
    }
    
    func setBeltOverlay(newHeight: CGFloat) {
        self.beltOverlay.frame.origin.y = newHeight
    }
    
    func setOverlayHeight(newHeight: CGFloat) {
        self.overlay.frame.origin.y = newHeight
    }
    
    func setStartingOverlayHeight() {
        overlay.frame.origin.y = ((view.frame.height / 2) * 0.8) - 65
    }
    
    func setOverlayAlpha(alpha: CGFloat) {
        overlay.alpha = alpha
    }
    
    func setBottomViewHeight(newHeight: CGFloat) {
        if let topViewController = viewControllers?[0] as? CardViewController {
            topViewController.setBottomViewHeight(newHeight: newHeight)
        }
    }
    
    func imageHeight() -> CGFloat {
        return view.frame.height / 2
    }
    
    func addBeltOverlay() {
        beltOverlay = BeltOverlayView.fromNib()
        beltOverlay.frame = CGRect(x: 0, y: view.frame.height - ((view.frame.height / 2) * 0.8 ) - 65, width: view.frame.width, height: 70)
        beltOverlay.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        view.addSubview(beltOverlay)
    }
    
    func bindScene(scene: Scene) {
        clearConstellations()
        _tripId = scene.tripId!
        currentIndex = scene.sceneOrder! - 1
        getTrip()
        beltOverlay.bindView(scene: scene, owner: (scene.trip?.owner!)!, card: scene.cards[0])
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        addOverlays()
        placeBackButton()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addOverlays() {
        overlay = UIView()
        overlay.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 70)
        overlay.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        view.addSubview(overlay)
    }
    
    func placeBackButton() {
        let statusBarHeight = UIApplication.shared.statusBarFrame.height * 0.66
        let xPosition = view.frame.width - 45
        let yPositionOffset = (60 - statusBarHeight) / 2 - 12.5
        let yPosition = statusBarHeight + yPositionOffset
        let buttonPosition = CGRect(x: xPosition, y: yPosition, width: 25, height: 25)
        let backButton = XBackButton(frame: buttonPosition)
        backButton.addTarget(self, action: #selector(dismissView), for: .touchUpInside)
        overlay.addSubview(backButton)
    }
    
    func placeStartTripButton() {
        
    }
    
    func getTrip() {
        tripsService.getTrip(_tripId, callback: self.setCardViewControllers)
    }
    
    func dismissView(sender: AnyObject) {
       view.removeFromSuperview()
       removeFromParentViewController()
        
        if delegate != nil {
            tripDelegate?.onDismissed()
        }
    }
    
    func setCardViewControllers(trip: Trip) {
        _trip = trip
        cardViewControllers = trip.scenes.map({ scene in
            let viewController = CardViewController(card: scene.cards[0], owner: trip.owner!, scene: scene)
            viewController.delegate = self
            return viewController
        })
        
        dataSource = self
        delegate = self

        
        drawConstellations(scenes: trip.scenes)
        jumpToSelectedScene()
    }
    
    func clearConstellations() {
        constellationPoints.forEach({ view in
            view.removeFromSuperview()
        })
    }
    
    func setDrawerMode() {
        setBeltOverlay(newHeight: 0.0)
        setOverlayHeight(newHeight: 0.0)
        setOverlayAlpha(alpha: 0.0)
        
    }

    func jumpToSelectedScene() {
        let vc = cardViewControllers[currentIndex]
        setViewControllers([vc], direction: .forward, animated: true, completion: nil)
        activateConstellation(constellationPoints[currentIndex])
    }
    
    func activateConstellation(_ constellation: UIView) {
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.0, initialSpringVelocity: 0.0, options: UIViewAnimationOptions.curveEaseInOut, animations: ({
            constellation.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            constellation.backgroundColor = UIColor.white.withAlphaComponent(1.0)
        }), completion: nil)
    }
    
    func deactivateConstellation(_ constellation: UIView) {
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.0, initialSpringVelocity: 0.0, options: UIViewAnimationOptions.curveEaseInOut, animations: ({
            constellation.transform = CGAffineTransform.identity
            constellation.backgroundColor = UIColor.white.withAlphaComponent(0.6)
        }), completion: nil)
    }
    
    func drawConstellations(scenes: [Scene]) {
        var xPosition = 10.0
        constellationPoints = scenes.map({ scene in
            let constellation = UIView()
            let yPosition = 30.00 * (scene.constellationPoint?.deltaY)! + 20
            var distanceToNextPoint = (scene.constellationPoint?.distanceToThePreviousPoint)!
            distanceToNextPoint = distanceToNextPoint > 1.0 ? 1.0 + drand48() : distanceToNextPoint
            xPosition += 25.00 * distanceToNextPoint
            xPosition += 15
            constellation.frame = CGRect(x: xPosition, y: yPosition, width: 8, height: 8)
            constellation.backgroundColor = UIColor.white.withAlphaComponent(0.6)
            constellation.makeCircle()
            return constellation
        })
        
        constellationPoints.forEach({ constellation in
            overlay.addSubview(constellation)
        })
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = cardViewControllers.index(of: viewController as! CardViewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else {
            return nil
        }
        
        guard cardViewControllers.count > previousIndex else {
            return nil
        }
        
        return cardViewControllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = cardViewControllers.index(of: viewController as! CardViewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = cardViewControllers.count
        
        guard orderedViewControllersCount != nextIndex else {
            return nil
        }
        
        guard orderedViewControllersCount > nextIndex else {
            return nil
        }
        
        return cardViewControllers[nextIndex]
    }
    
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController],
                            transitionCompleted completed: Bool) {
        if (!completed) {
            return
        }
        
        let previousIndex = cardViewControllers.index(of: previousViewControllers[0] as! CardViewController)!
        guard let currentIndex = cardViewControllers.index(of: pageViewController.viewControllers?.first as! CardViewController) else {
            return
        }
        activateConstellation(constellationPoints[currentIndex])
        deactivateConstellation(constellationPoints[previousIndex])
        let currentScene = _trip.scenes[currentIndex]
        beltOverlay.bindView(scene: currentScene, owner: _trip!.owner!, card: currentScene.cards[0])
        
        if tripDelegate != nil {
            tripDelegate?.onSceneChanged(_trip.scenes[currentIndex])
        }
    
    }

    func createProfileView(user: User) {
        profileView = ProfileView.fromNib("ProfileView")
        profileView.frame = view.frame
        profileView.delegate = self
        profileView.initializeView(user)
        view.addSubview(profileView)
        addXBackButton()
    }
    
    func addXBackButton() {
        let frame = CGRect(x: view.bounds.width - 45, y: 30, width: 30, height: 30)
        xBackButton = XBackButton(frame: frame)
        xBackButton.addTarget(self, action: #selector(dismissProfile), for: .touchUpInside)
        view.addSubview(xBackButton)
    }
    
    func dismissProfile() {
        profileView.removeFromSuperview()
        xBackButton.removeFromSuperview()
    }
    
    func onLoggedOut() {}

}
