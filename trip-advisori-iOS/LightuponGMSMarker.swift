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

let markerDiameter = 40

class LightuponGMSMarker: GMSMarker {
    var _scene: Scene
    var _image: UIImage?
    var _selectedImage: UIImage?
    
    init(scene: Scene) {
        _scene = scene
        super.init()
        position = CLLocationCoordinate2DMake(scene.latitude!, scene.longitude!)
        title = scene.name
        userData = scene
    }
    
    func setImages(_ image: UIImage, map: LightuponGMSMapView) {
        _image = Toucan(image: image).resize(CGSize(width: markerDiameter, height: markerDiameter), fitMode: Toucan.Resize.FitMode.scale).maskWithEllipse().image
        _selectedImage = Toucan(image: image).resize(CGSize(width: map.frame.width/3.5, height: map.frame.width/3.5), fitMode: Toucan.Resize.FitMode.scale).maskWithEllipse(borderWidth: 5, borderColor: UIColor.white).image
    }
    func setSelected() {
        icon = nil
        icon = _selectedImage?.withAlignmentRectInsets(UIEdgeInsetsMake(0, 0, ((_selectedImage?.size.height)!/2), 0))
        zIndex = 1
    }
    
    func setNotSelected() {
        icon = nil
        icon = _image
        zIndex = 0
    }
    
    var scene: Scene {
        get {
            return _scene
        }
    }

}
