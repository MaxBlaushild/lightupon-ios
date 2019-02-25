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
    private var _lockState: LockState = .locked
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
        super.init(coder: aDecoder)
        
        currentLocationService.registerDelegate(self)
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
    
    func setUnlockedState() {
        settings.scrollGestures = true
        settings.rotateGestures = true
        settings.tiltGestures = true
        settings.zoomGestures = true
    }
    
    func toggleLock() {
        lockState = lockState == .locked ? .unlocked : .locked
    }
    
    func onHeadingUpdated() {
        realignMapView()
    }
    
    func unselect() {
        if let selectedMarker = selectedLightuponMarker {
            selectedMarker.setNotSelected()
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
    
    func bindPosts(_ posts: [Post]) {
        for post in posts {
            if let _ = markerFromPostID(post.id) { } else {
                placeMarker(post: post)
            }
        }
    }
    
    func clearMarkers() {
        markers.forEach({ marker in
            marker.map = nil
        })
        markers = [LightuponGMSMarker]()
    }
    
    
    func updateFrame() {
        let post = selectedLightuponMarker!.post
        animate(
            to: GMSCameraPosition.camera(
                withLatitude: post.latitude!,
                longitude: post.longitude!,
                zoom: googleMapsService.defaultUnlockedZoom,
                bearing: camera.bearing,
                viewingAngle: camera.viewingAngle
            )
        )
    }
    
    func selectMarker(_ marker: LightuponGMSMarker) {
        selectedLightuponMarker?.setNotSelected()
        marker.setSelected()
//        centerMapOnScreen()
        selectedLightuponMarker = marker
        updateFrame()
    }
    
    func centerMapOnScreen() {
        UIView.animate(withDuration: 0.25, animations: {
            self.frame = CGRect(
                x: 0,
                y: 0,
                width: self.frame.width,
                height: 100
            )
        })
    }
    
    func markerFromPostID(_ postID: Int) -> LightuponGMSMarker? {
        return markers.first(where:{$0.post.id == postID})
    }
    
    func findOrCreateMarker(post: Post, blurApplies: Bool)  -> LightuponGMSMarker? {
        let marker = markerFromPostID(post.id)
        
        if marker != nil {
            marker?.updateImages()
        }
        return marker == nil ? createMarkerSync(post: post) : marker
    }
    
    private func createMarkerSync(post: Post) -> LightuponGMSMarker {
        let marker = LightuponGMSMarker(post: post)
        marker.setImages(mapView: self, selected: true)
        return marker
        
    }
    
    func placeMarker(post: Post) {
        let marker = LightuponGMSMarker(post: post)
        markers.append(marker)
        marker.setImages(mapView: self, selected: false)
        marker.map = self
    }
}


