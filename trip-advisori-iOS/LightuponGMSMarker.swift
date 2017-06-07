//
//  LightuponGMSMarker.swift
//  Lightupon
//
//  Created by Blaushild, Max on 2/5/17.
//  Copyright © 2017 Blaushild, Max. All rights reserved.
//

import UIKit
import GoogleMaps
import Toucan
import Alamofire

let markerDiameter = 40

class LightuponGMSMarker: GMSMarker {
    private var feedService = Services.shared.getFeedService()
    
    var _scene: Scene
    var _image: UIImage?
    var _selectedImage: UIImage?
    var _selected: Bool = false
    
    init(scene: Scene) {
        _scene = scene
        super.init()
        position = CLLocationCoordinate2DMake(scene.latitude!, scene.longitude!)
        title = scene.name
        userData = scene
         NotificationCenter.default.addObserver(self, selector: #selector(onSceneUpdated), name: feedService.sceneUpdatedSubscriptionName, object: nil)
    }
    
    func onSceneUpdated(notification: NSNotification) {
        let sceneID = notification.object as! Int
//        let utilityQueue = DispatchQueue.global(qos: .utility)
        if sceneID == _scene.id {
//            DispatchQueue.global(qos: .userInteractive).async {
                self.feedService.getScene(sceneID, success: { scene in
                    self._scene = scene
                    self.updateImages(blurApplies: true)
                })
//            }
        }
    }
    
    func setImages(mapView: LightuponGMSMapView, selected: Bool, blurApplies: Bool) {
        if let pinUrl = _scene.pinUrl {
            Alamofire.request(pinUrl).responseJSON { response in
                let blur = 1.0 - self._scene.percentDiscovered
                if let data = response.data {
                    var image = UIImage(data: data)
                    if blurApplies && blur > 0.001 {
                        image = image?.applyBackToTheFutureEffect(blur: blur)
                    }
                    if let img = image {
                        self._image = Toucan(image: img).resize(CGSize(width: markerDiameter, height: markerDiameter), fitMode: Toucan.Resize.FitMode.scale).maskWithEllipse().image
                        self._selectedImage = Toucan(image: img).resize(CGSize(width: 120, height: 120), fitMode: Toucan.Resize.FitMode.scale).maskWithEllipse(borderWidth: 5, borderColor: UIColor.white).image
                        
                        self.map = mapView
                        mapView.markers.append(self)
                        
                        if selected {
                            self.setSelected()
                        } else {
                            self.setNotSelected()
                        }
                    }
                }
            }
        }
    }
    
    func updateImages(blurApplies: Bool) {
        _image = nil
        _selectedImage = nil
        let backgroundQueue = DispatchQueue.global(qos: .background)
        
        if let pinUrl = _scene.pinUrl {
            Alamofire.request(pinUrl).responseJSON(queue: backgroundQueue) { response in
                let blur = 1.0 - self._scene.percentDiscovered
                if let data = response.data {
                    var image = UIImage(data: data)
                    if blurApplies && blur > 0.001 {
                        image = image?.applyBackToTheFutureEffect(blur: blur)
                    }
                    if let img = image {
                        self._image = Toucan(image: img).resize(CGSize(width: markerDiameter, height: markerDiameter), fitMode: Toucan.Resize.FitMode.scale).maskWithEllipse().image
                        self._selectedImage = Toucan(image: img).resize(CGSize(width: 120, height: 120), fitMode: Toucan.Resize.FitMode.scale).maskWithEllipse(borderWidth: 5, borderColor: UIColor.white).image
                        
                        if self._selected {
                            self.setSelected()
                        } else {
                            self.setNotSelected()
                        }
                    }
                }
            }
        }
    }
    
    func setSelected() {
        icon = nil
        icon = _selectedImage?.withAlignmentRectInsets(UIEdgeInsetsMake(0, 0, ((_selectedImage?.size.height)!/2), 0))
        zIndex = 1
        _selected = true
    }
    
    func setNotSelected() {
        icon = nil
        icon = _image
        zIndex = 0
        _selected = false
    }
    
    var scene: Scene {
        get {
            return _scene
        }
    }
}
