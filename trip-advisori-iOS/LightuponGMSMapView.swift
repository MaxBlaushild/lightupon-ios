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
let selectedZoom: Float = 15.0
let unselectedZoom: Float = 18.0

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
        settings.myLocationButton = true
        settings.tiltGestures = false
        settings.zoomGestures = false
        centerMap()
        lockButton.setImage(UIImage(named: "locked"), for: .normal)
        setCompassFrame()
        
        if let lightDelegate = lightuponDelegate {
            lightDelegate.onLocked()
        }
    }
    
    func setCompassFrame() {
        UIView.animate(withDuration: 0.25, animations: {
            self.frame = self._initialFrame
        })
    }
    
    func watercolored() {
        let urls: GMSTileURLConstructor = {(x, y, zoom) in
            let url = "http://tile.stamen.com/watercolor/\(zoom)/\(x)/\(y).jpg"
            return URL(string: url)
        }
        
        // Create the GMSTileLayer
        let layer = GMSURLTileLayer(urlConstructor: urls)
        
        // Display on the map at a specific zIndex
        layer.zIndex = 100
        layer.map = self
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
            x: frame.width - 70,
            y: frame.height / 2,
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
            zoom: unselectedZoom
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
            zoom: 15,
            bearing: currentLocationService.heading,
            viewingAngle: 0
        )
    }
    
    func onLocationUpdated() {
        centerMapOnLocation()
    }
    
    func bindScenes(_ scenes: [Scene]) {
        clearMarkers()
        for scene in scenes {
            placeMarker(scene: scene)
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
                withLatitude: scene.latitude!,
                longitude: scene.longitude!,
                zoom: selectedZoom,
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
            self.frame = UIScreen.main.bounds
        })
    }
    
    func findOrCreateMarker(scene: Scene)  -> LightuponGMSMarker? {
        let marker = markers.first(where:{$0.scene.id == scene.id})
        return marker == nil ? createMarkerSync(scene: scene) : marker
    }
    
    private func createMarkerSync(scene: Scene) -> LightuponGMSMarker {
        let marker = LightuponGMSMarker(scene: scene)
        marker.setImages(mapView: self, selected: true)
        return marker
        
    }
    
    func placeMarker(scene: Scene) {
        let marker = LightuponGMSMarker(scene: scene)
        marker.setImages(mapView: self, selected: false)
    }
}


