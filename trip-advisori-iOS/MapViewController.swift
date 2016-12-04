//
//  MapViewController.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 1/30/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//

import UIKit
import GoogleMaps

class MapViewController: UIViewController, GMSMapViewDelegate, TripDetailsViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    fileprivate let currentLocationService = Injector.sharedInjector.getCurrentLocationService()
    fileprivate let tripsService = Injector.sharedInjector.getTripsService()
    fileprivate let litService = Injector.sharedInjector.getLitService()
    fileprivate let userService = Injector.sharedInjector.getUserService()
    fileprivate let postService = Injector.sharedInjector.getPostService()
    fileprivate let socketService = Injector.sharedInjector.getSocketService()
    
    var trips:[Trip]!
    var blurView: BlurView!
    var tripDetailsView:TripDetailsView!
    var xBackButton:XBackButton!
    var delegate: MainViewControllerDelegate!
    var imagePicker = UIImagePickerController()
    var mapMenuView: UIView!
    var mainButton: UIButton!
    var postButton: UIButton!
    var messageButton: UIButton!
    var litButton: UIButton!
    var menuOpen:Bool = false
    
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var ImagePicked: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getTrips()
        configureMapView()
        addMainButton()
        imagePicker.delegate = self;
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var shouldAutorotate : Bool {
        return false
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
    
    @IBAction func openMenu(_ sender: AnyObject) {
        delegate.toggleRightPanel()
    }
    
    func toggleLitness(_ sender: AnyObject) {
        litService.isLit ? extinguish() : light()
    }

    
    func openCameraButton(sender: AnyObject) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            imagePicker.sourceType = .camera
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject], editingInfo: [NSObject : AnyObject]!) {
        ImagePicked.image = info[UIImagePickerControllerOriginalImage] as! UIImage?
        self.dismiss(animated: true, completion: nil);
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func confirmSent(_ sender: AnyObject) {
        let imageData = UIImageJPEGRepresentation(ImagePicked.image!, 0.6)
        let compressedJPGImage = UIImage(data: imageData!)
        UIImageWriteToSavedPhotosAlbum(compressedJPGImage!, nil, nil, nil)
        
//        let alert = UIAlertController(title: "Wow",
//                                message: "Your image has been saved to Photo Library!",
//                                delegate: nil,
//                                cancelButtonTitle: "Ok")
//        alert.show()
        postService.sendPicture(name: "farts", type: "images", callback: self.closeImageView)
    }
    
    func addMainButton() {
        mainButton = UIButton()
        mainButton.frame = CGRect(x: view.frame.width / 2 - 30, y: view.frame.height - 167, width: 60, height: 60)
        setUnopenedMainButtonState()
        mainButton.makeCircle()
        view.insertSubview(mainButton, at: 0)
        view.bringSubview(toFront: mainButton)
    }
    
    func setUnopenedMainButtonState() {
        let image = UIImage(named: "whiteLogo") as UIImage?
        mainButton.backgroundColor = Colors.basePurple
        mainButton.setImage(image, for: .normal)
        mainButton.removeTarget(self, action: #selector(closeMapMenu), for: .touchUpInside)
        mainButton.addTarget(self, action: #selector(openMapMenu), for: .touchUpInside)
    }
    
    func setOpenedMainButtonState() {
        let image = UIImage(named: "mainCancel") as UIImage?
        mainButton.setImage(image, for: .normal)
        mainButton.removeTarget(self, action: #selector(openMapMenu), for: .touchUpInside)
        mainButton.backgroundColor = UIColor.white
        mainButton.addTarget(self, action: #selector(closeMapMenu), for: .touchUpInside)
    }
    
    func openMapMenu(sender: UIButton!) {
        toggleMainButton()
        createMapMenu()
        view.addSubview(mapMenuView)
        view.bringSubview(toFront: mainButton)
        animateInMapMenu()
        addLitButton()
        animateInLitButton()
        addPostButton()
        animateInPostButton()
        addMessageButton()
        animateInMessageButton()
    }
    
    func closeMapMenu() {
        mainButton.isEnabled = false
        animateOutButtons()
        animateOutMenu()
    }
    
    func removeMapMenuViews() {
        removeMapView()
        removeLitButton()
        removePostButton()
        removeMessageButton()
        toggleMainButton()
    }
    
    func removeMapView() {
        mapMenuView.removeFromSuperview()
        mapMenuView = nil
    }
    
    func removeLitButton() {
        litButton.removeFromSuperview()
        litButton = nil
    }
    
    func removePostButton() {
        postButton.removeFromSuperview()
        postButton = nil
    }
    
    func removeMessageButton() {
        messageButton.removeFromSuperview()
        messageButton = nil
    }
    
    func toggleMainButton() {
        menuOpen ? setUnopenedMainButtonState() : setOpenedMainButtonState()
        menuOpen = !menuOpen
        mainButton.isEnabled = true
    }
    
    func createMapMenu() {
        mapMenuView = UIView()
        mapMenuView.frame = view.frame
        mapMenuView.frame.origin.y = view.frame.height
        mapMenuView.backgroundColor = Colors.basePurple
        mapMenuView.alpha = 0.6
    }
    
    func addPostButton() {
        postButton = UIButton()
        let image = UIImage(named: "post") as UIImage?
        postButton.setImage(image, for: .normal)
        postButton.addTarget(self, action: #selector(openCameraButton), for: .touchUpInside)
        postButton.backgroundColor = UIColor.white
        postButton.alpha = 1.0
        postButton.frame = CGRect(x: view.frame.width / 2 - 20, y: view.frame.height - 147, width: 40, height: 40)
        postButton.makeCircle()
        view.addSubview(postButton)
    }
    
    func addMessageButton() {
        messageButton = UIButton()
        let image = UIImage(named: "message") as UIImage?
        messageButton.setImage(image, for: .normal)
        messageButton.backgroundColor = UIColor.white
        messageButton.alpha = 1.0
        messageButton.frame = CGRect(x: view.frame.width / 2 - 20, y: view.frame.height - 147, width: 40, height: 40)
        messageButton.makeCircle()
        view.addSubview(messageButton)
    }
    
    func addLitButton() {
        litButton = UIButton()
        litButton.backgroundColor = UIColor.white
        litButton.alpha = 1.0
        litButton.addTarget(self, action: #selector(toggleLitness), for: .touchUpInside)
        bindLitness()
        view.bringSubview(toFront: litButton)
        litButton.frame = CGRect(x: view.frame.width / 2 - 20, y: view.frame.height - 147, width: 40, height: 40)
        litButton.makeCircle()
        view.addSubview(litButton)
    }
    
    func animateInPostButton() {
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.0, initialSpringVelocity: 0.0, options: UIViewAnimationOptions.curveEaseInOut, animations: ({
            self.postButton.frame = CGRect(x: self.view.frame.width / 2 - 20, y: self.view.frame.height - 267, width: 40, height: 40)
        }), completion: nil)
    }
    
    func animateInLitButton() {
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.0, initialSpringVelocity: 0.0, options: UIViewAnimationOptions.curveEaseInOut, animations: ({
            self.litButton.frame = CGRect(x: self.view.frame.width / 2 - 100, y: self.view.frame.height - 217, width: 40, height: 40)
        }), completion: nil)
    }
    
    func animateInMessageButton() {
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.0, initialSpringVelocity: 0.0, options: UIViewAnimationOptions.curveEaseInOut, animations: ({
            self.messageButton.frame = CGRect(x: self.view.frame.width / 2 + 60, y: self.view.frame.height - 217, width: 40, height: 40)
        }), completion: nil)
    }
    
    func animateInMapMenu() {
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 20.0, initialSpringVelocity: 0.0, options: UIViewAnimationOptions.curveEaseInOut, animations: ({
            self.mapMenuView.frame = self.view.frame
        }), completion: nil)
    }
    
    func animateOutMenu() {
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 20.0, initialSpringVelocity: 0.0, options: UIViewAnimationOptions.curveEaseInOut, animations: ({
            self.mapMenuView.frame.origin.y = self.view.frame.height
        }), completion: { truth in
            self.removeMapMenuViews()
        })
    }
    
    func animateOutButtons() {
        view.bringSubview(toFront: mainButton)
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 10.0, initialSpringVelocity: 0.0, options: UIViewAnimationOptions.curveEaseInOut, animations: ({
            let origin = CGRect(x: self.view.frame.width / 2 - 20, y: self.view.frame.height - 167, width: 40, height: 40)
            self.messageButton.frame = origin
            self.postButton.frame = origin
            self.litButton.frame = origin
        }), completion: nil)
    }
    
    func configureMapView() {
        mapView.camera = GMSCameraPosition.camera(withLatitude: currentLocationService.latitude, longitude: currentLocationService.longitude, zoom: 15)
        mapView.isMyLocationEnabled = true
        mapView.delegate = self
    }
    
    func getTrips() {
        tripsService.getTrips(self.onTripsGotten, latitude: self.currentLocationService.latitude, longitude: self.currentLocationService.longitude)
    }
    
    func closeImageView() {
        
    }
    
    func light() {
        litService.light(successCallback: self.bindLitness)
    }
    
    func extinguish() {
        litService.extinguish(successCallback: self.bindLitness)
    }
    
    func bindLitness() {
        let title = litService.isLit ? "Lit" : "Not"
        litButton.setTitleColor(Colors.basePurple, for: UIControlState.normal)
        litButton.setTitle(title, for: .normal)
    }
    
    func onTripsGotten(_ _trips_: [Trip]) {
        trips = _trips_
        initMap()
    }
    
    func initMap() {
        for trip in trips {
            placeTripOnMap(trip, mapView: mapView)
        }
    }

    func getRandomColor() -> UIColor{
        let randomRed:CGFloat = CGFloat(drand48())
        let randomGreen:CGFloat = CGFloat(drand48())
        let randomBlue:CGFloat = CGFloat(drand48())
        return UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 1.0)
    }
    
    func placeTripOnMap(_ trip: Trip, mapView: GMSMapView) {
        let colorForTrip = getRandomColor()
        placeLocations(trip: trip, color: colorForTrip)
        placeMarkers(trip: trip, color: colorForTrip)

    }
    
    func placeLocations(trip: Trip, color: UIColor) {
        if trip.locations != nil {
            let path = GMSMutablePath()
            
            for location in trip.locations {
                let coord = CLLocationCoordinate2D(latitude: location.latitude!, longitude: location.longitude!)
                path.add(coord)
            }
            
            let polyline = GMSPolyline(path: path)
            polyline.strokeColor = color
            polyline.map = mapView
        }

    }
    
    func placeMarkers(trip: Trip, color: UIColor) {
        if trip.scenes != nil {
            for scene in trip.scenes! {
                placeMarker(scene: scene, color: color)
            }
        }
    }
    
    func placeMarker(scene: Scene, color: UIColor) {
        let marker = GMSMarker()
        marker.icon = GMSMarker.markerImage(with: color)
        marker.position = CLLocationCoordinate2DMake(scene.latitude!, scene.longitude!)
        marker.title = scene.name
        marker.userData = scene
        marker.map = mapView
    }
    
    func onDismissed() {
        tripDetailsView.removeFromSuperview()
        blurView.removeFromSuperview()
        xBackButton.removeFromSuperview()
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        obscureBackground()
        tripDetailsView = TripDetailsView.fromNib("TripDetailsView")
        tripDetailsView.delegate = self
        tripDetailsView.size(self)
        let scene = marker.userData as! Scene
        tripDetailsView.bindCard((scene.cards?[0])!, tripId: scene.tripId!)
        view.addSubview(tripDetailsView)
        return true
    }
    
    func segueToContainer() {
        performSegue(withIdentifier: "MapToContainer", sender: self)
    }
    
    func obscureBackground() {
        blurBackground()
        addXBackButton()
    }
    
    func addXBackButton() {
        let frame = CGRect(x: view.bounds.width - 45, y: 30, width: 30, height: 30)
        xBackButton = XBackButton(frame: frame)
        xBackButton.addTarget(self, action: #selector(onDismissed), for: .touchUpInside)
        view.addSubview(xBackButton)
    }
    
    func blurBackground() {
        blurView = BlurView(onClick: onDismissed)
        blurView.frame = view.bounds
        view.addSubview(blurView)
    }

}
