//
//  LightuponGMSMapView.swift
//  Lightupon
//
//  Created by Blaushild, Max on 2/5/17.
//  Copyright © 2017 Blaushild, Max. All rights reserved.
//

import UIKit
import GoogleMaps
import Alamofire

enum LockState {
    case locked, unlocked
}

protocol LightuponGMSMapViewDelegate {
    func onLocked() -> Void
}

class LightuponGMSMapView: GMSMapView, CurrentLocationServiceDelegate {
    private let googleMapsService = Services.shared.getGoogleMapsService()
    private let currentLocationService = Services.shared.getCurrentLocationService()
    
    private var _initialFrame: CGRect!
    private var _lockState: LockState
    public var markers = [LightuponGMSMarker]()
    private var directions: [GMSPolyline] = [GMSPolyline]()
    private var lockButton: UIButton!
    
    public var selectedLightuponMarker: LightuponGMSMarker?
    public var lightuponDelegate: LightuponGMSMapViewDelegate?
    
    public var lockState: LockState {
        get {
            return _lockState
        }
        
        set {
            _lockState = newValue
            switch _lockState {
            case .locked:
                setLockedState()
            case .unlocked:
                setUnlockedState()
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        _lockState = .locked
        
        super.init(coder: aDecoder)
        
        currentLocationService.registerDelegate(self)
        
        addLockButton()
        
        isMyLocationEnabled = true
        _initialFrame = frame
        lockState = .locked
    }
    
    func setLockedState() {
        selectedLightuponMarker?.setNotSelected()
        settings.scrollGestures = false
        settings.rotateGestures = false
        settings.myLocationButton = false
        settings.tiltGestures = false
        settings.zoomGestures = false
        centerMap()
        lockButton.setImage(UIImage(named: "locked"), for: .normal)
        setCompassFrame()
        
        if let lightDelegate = lightuponDelegate {
            lightDelegate.onLocked()
        }
    }
    
    func getCenterCoordinate() -> CLLocationCoordinate2D {
        let bounds = UIScreen.main.bounds
        let centerPoint = CGPoint(x: bounds.height / 2, y: bounds.width / 2)
        let centerCoordinate = self.projection.coordinate(for: centerPoint)
        return centerCoordinate
    }
    
    func getTopCenterCoordinate() -> CLLocationCoordinate2D {
        // to get coordinate from CGPoint of your map
        let topCenterCoor = self.convert(CGPoint(x: self.frame.size.width, y: 0), from: self)
        let point = self.projection.coordinate(for: topCenterCoor)
        return point
    }
    
    func getRadius() -> CLLocationDistance {
        let centerCoordinate = getCenterCoordinate()
        let centerLocation = CLLocation(latitude: centerCoordinate.latitude, longitude: centerCoordinate.longitude)
        let topCenterCoordinate = self.getTopCenterCoordinate()
        let topCenterLocation = CLLocation(latitude: topCenterCoordinate.latitude, longitude: topCenterCoordinate.longitude)
        let radius = CLLocationDistance(centerLocation.distance(from: topCenterLocation))
        return round(radius)
    }
    
    func setCompassFrame() {
        UIView.animate(withDuration: 0.25, animations: {
            self.frame = CGRect(
                x: self._initialFrame.minX,
                y: self._initialFrame.minY,
                width: UIScreen.main.bounds.width,
                height: self._initialFrame.height
            )
        })
    }
    
    func setUnlockedState() {
        settings.scrollGestures = true
        settings.rotateGestures = true
        settings.tiltGestures = true
        settings.zoomGestures = true
        clearDirections()
        lockButton.setImage(UIImage(named: "unlocked"), for: .normal)
    }
    
    func addLockButton() {
        lockButton = UIButton()
        lockButton.backgroundColor = .white
        lockButton.frame = CGRect(
            x: UIScreen.main.bounds.width - 70,
            y: UIScreen.main.bounds.height - 175,
            width: 50,
            height: 50
        )
        lockButton.addTarget(self, action: #selector(toggleLock), for: .touchUpInside)
        lockButton.setImage(UIImage(named: "locked"), for: .normal)
        addSubview(lockButton)
    }
    
    func toggleLock() {
        lockState = lockState == .locked ? .unlocked : .locked
    }
    
    func onHeadingUpdated() {
        realignMapView()
    }
    
    func unselect() {
        if let selectedScene = selectedLightuponMarker {
            selectedScene.setNotSelected()
            clearDirections()
        }
    }
    
    func centerMap() {
        animate(to: GMSCameraPosition.camera(
            withLatitude: currentLocationService.latitude,
            longitude: currentLocationService.longitude,
            zoom: googleMapsService.defaultLockedZoom
        ))
    }
    
    func realignMapView() {
        if lockState == .locked {
            let heading = currentLocationService.heading
            self.animate(toBearing: heading)
        }
    }
    
    func centerMapOnLocation() {
        let newCenter = createCenteredCameraPostion()
        self.animate(to: newCenter)
    }
    
    func createCenteredCameraPostion() -> GMSCameraPosition {
        return GMSCameraPosition.camera(
            withLatitude: currentLocationService.latitude,
            longitude: currentLocationService.longitude,
            zoom: camera.zoom,
            bearing: currentLocationService.heading,
            viewingAngle: 0
        )
    }
    
    func onLocationUpdated() {
        centerMapOnLocation()
    }
    
    func bindScenes(_ scenes: [Scene]) {
//        clearMarkers()
        for scene in scenes {
            if let _ = markerFromSceneID(scene.id) { } else {
                placeMarker(scene: scene)
            }
        }
    }
    
    func clearMarkers() {
        markers.forEach({ marker in
            marker.map = nil
        })
        markers = [LightuponGMSMarker]()
    }
    
    func clearDirections() {
        directions.forEach({ direction in
            direction.map = nil
        })
        directions = [GMSPolyline]()
    }
    
    func drawLine(_ path: GMSPath) {
        let singleLine = GMSPolyline(path: path)
        singleLine.strokeWidth = 5
        singleLine.strokeColor = UIColor.basePurple
        singleLine.map = self
        directions.append(singleLine)
    }
    
    func drawDirections() {
        let trip = selectedLightuponMarker!.scene.trip!
        let totalScenes = trip.scenes.count
        for (index, currentScene) in trip.scenes.enumerated() {
            let nextSceneIndex = index + 1
            if nextSceneIndex != totalScenes {
                let nextScene = trip.scenes[nextSceneIndex]
                
                googleMapsService.getDirections(
                    origin: currentScene.location,
                    destination:
                    nextScene.location,
                    callback: { path in
                        self.drawLine(path)
                    })
            }
        }
    }
    
    func updateFrame() {
        let scene = selectedLightuponMarker!.scene
        animate(
            to: GMSCameraPosition.camera(
                withLatitude: scene.latitude,
                longitude: scene.longitude,
                zoom: googleMapsService.defaultUnlockedZoom,
                bearing: camera.bearing,
                viewingAngle: camera.viewingAngle
            )
        )
    }
    
    func selectMarker(_ marker: LightuponGMSMarker) {
        selectedLightuponMarker?.setNotSelected()
        marker.setSelected()
        centerMapOnScreen()
        selectedLightuponMarker = marker
        updateFrame()
    }
    
    func centerMapOnScreen() {
        UIView.animate(withDuration: 0.25, animations: {
            self.frame = CGRect(
                x: 0,
                y: UIApplication.shared.statusBarFrame.height,
                width: self.frame.width,
                height: UIScreen.main.bounds.height - UIApplication.shared.statusBarFrame.height
            )
        })
    }
    
    func markerFromSceneID(_ sceneID: Int) -> LightuponGMSMarker? {
        return markers.first(where:{$0.scene.id == sceneID})
    }
    
    func findOrCreateMarker(scene: Scene, blurApplies: Bool)  -> LightuponGMSMarker? {
        let marker = markerFromSceneID(scene.id)
        
        if marker != nil {
            marker?.updateImages(blurApplies: false)
        }
        return marker == nil ? createMarkerSync(scene: scene) : marker
    }
    
    private func createMarkerSync(scene: Scene) -> LightuponGMSMarker {
        let marker = LightuponGMSMarker(scene: scene)
        marker.setImages(mapView: self, selected: true, blurApplies: false)
        return marker
        
    }
    
    func placeMarker(scene: Scene) {
        let marker = LightuponGMSMarker(scene: scene)
        markers.append(marker)
        marker.setImages(mapView: self, selected: false, blurApplies: true)
    }
}


