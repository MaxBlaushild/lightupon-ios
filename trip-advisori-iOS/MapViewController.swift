//
//  MapViewController.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 1/30/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//

import UIKit
import GoogleMaps
import Alamofire

class MapViewController: UIViewController, GMSMapViewDelegate, TripDetailsViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    
    let reuseIdentifier = "MapSceneCell"
    
    fileprivate let currentLocationService = Injector.sharedInjector.getCurrentLocationService()
    fileprivate let tripsService = Injector.sharedInjector.getTripsService()
    fileprivate let litService = Injector.sharedInjector.getLitService()
    fileprivate let userService = Injector.sharedInjector.getUserService()
    fileprivate let postService = Injector.sharedInjector.getPostService()
    fileprivate let socketService = Injector.sharedInjector.getSocketService()
    fileprivate let feedService = Injector.sharedInjector.getFeedService()
    
    var trips:[Trip]!
    var blurView: BlurView!
    var scenes: [Scene] = [Scene]()
    var xBackButton:XBackButton!
    var delegate: MainViewControllerDelegate!
    var mapMenuView: UIView!
    var mainButton: UIButton!
    var postButton: UIButton!
    var messageButton: UIButton!
    var litButton: UIButton!
    var menuOpen:Bool = false
    
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var ImagePicked: UIImageView!
    @IBOutlet weak var MapSceneCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getScenes()
        MapSceneCollectionView.dataSource = self
        MapSceneCollectionView.delegate = self
        getTrips()
        configureMapView()
        addMainButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getTrips()
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
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return scenes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let scene: Scene = scenes[(indexPath as NSIndexPath).row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! MapSceneCell
        cell.MapSceneImage.imageFromUrl(scene.backgroundUrl!)
        cell.layer.cornerRadius = 6
        cell.layer.borderWidth = 2
        cell.layer.borderColor = UIColor(red:0.61, green:0.38, blue:0.81, alpha:1.0).cgColor
        return cell
    }

    
    func openCameraButton(sender: AnyObject) {
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera;
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    @objc(imagePickerController:didFinishPickingMediaWithInfo:) func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            postService.createSelfie(image: pickedImage, callback: {
                self.dismiss(animated: true, completion: nil);
            })
        }
    
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func addMainButton() {
        mainButton = UIButton()
        mainButton.frame = CGRect(x: view.frame.width / 2 - 30, y: view.frame.height - 167, width: 60, height: 60)
        setUnopenedMainButtonState()
        mainButton.makeCircle()
        view.insertSubview(mainButton, at: 0)
        view.bringSubview(toFront: mainButton)
    }
    
    func getScenes() {
        feedService.getFeed(success: self.addScenes)
    }
    
    func addScenes(_scenes: [Scene]) {
        scenes = _scenes
        MapSceneCollectionView.reloadData()
        self.bringMapSceneToFront()
    }
    
    func bringMapSceneToFront() {
        view.insertSubview(MapSceneCollectionView, at: 0)
        view.bringSubview(toFront: MapSceneCollectionView)
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
        mapView.settings.myLocationButton = true
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
            for scene in trip.scenes {
                scene.trip = trip
                let string = scene.backgroundUrl
                placeMarker(scene: scene, image: string!)
            }
        }
    }
    
    func createRoundedMarker(image: UIImage, radius: Float) -> UIImage {
        let imageView: UIImageView = UIImageView(image: image)
        var layer: CALayer = CALayer()
        layer = imageView.layer
        
        layer.masksToBounds = true
        layer.cornerRadius = CGFloat(radius)
        UIGraphicsBeginImageContext(imageView.bounds.size)
        layer.borderColor = UIColor(red: 255, green: 255, blue: 255, alpha: 1.0).cgColor
        layer.borderWidth = 4
        layer.render(in: UIGraphicsGetCurrentContext()!)
        let roundedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return roundedImage!
    }
    
    func resizeImage(image:UIImage, scaledToSize newSize:CGSize) -> UIImage{
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0);
        image.draw(in: CGRect(origin: CGPoint.zero, size: CGSize(width: newSize.width, height: newSize.height)))
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
    
    func placeMarker(scene: Scene, image: String) {
        Alamofire.request(image, method: .get, parameters: nil).responseJSON { (response) in

            let marker = GMSMarker()
            let image = response.response!.statusCode == 200 ? UIImage(data: response.data!, scale: 1) : UIImage(named: "banner")
            let loadedImage = self.resizeImage(image: image!, scaledToSize: CGSize(width: 60, height: 60))
            marker.position = CLLocationCoordinate2DMake(scene.latitude!, scene.longitude!)
            let roundedImage = self.createRoundedMarker(image: loadedImage, radius: 30)
            marker.icon = roundedImage
            marker.title = scene.name
            marker.userData = scene
            marker.map = self.mapView
        }
       
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        let scene: Scene = marker.userData as! Scene
        let tripDetailsViewController = TripDetailsViewController(scene: scene)
        addChildViewController(tripDetailsViewController)
        tripDetailsViewController.view.frame = view.frame
        view.addSubview(tripDetailsViewController.view)
        tripDetailsViewController.didMove(toParentViewController: self)
            return true

    }
    
    func segueToContainer() {
        performSegue(withIdentifier: "MapToContainer", sender: self)
    }

}
