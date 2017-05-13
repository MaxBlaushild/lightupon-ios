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
    
    func setImages(mapView: LightuponGMSMapView, selected: Bool) {
        if let pinUrl = _scene.pinUrl {
            Alamofire.request(pinUrl).responseJSON { response in
                if let data = response.data {
                    var image = UIImage(data: data)
                    if self._scene.blur > 0.001 {
                        image = image?.applyBackToTheFutureEffect(blur: self._scene.blur)
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
        
//        if let pinUrl = _scene.pinUrl {
//            Alamofire.request(pinUrl).responseJSON { response in
//                if let data = response.data {
//                    var image = UIImage(data: data)
//                    if self._scene.hidden {
//                        image = image?.applyDarkEffect()
//                    }
//                    if let img = image {
//                        self._image = img
//                        if self._selectedImage != nil {
//                            self.map = mapView
//                            mapView.markers.append(self)
//                            
//                            if selected {
//                                self.setSelected()
//                            } else {
//                                self.setNotSelected()
//                            }
//                        }
//                    }
//                    
//                }
//            }
//            
//        }
//        
//        if let selectedPinUrl = _scene.selectedPinUrl {
//            Alamofire.request(selectedPinUrl).responseJSON { response in
//                if let data = response.data {
//                    var selectedImage = UIImage(data: data)
//                    if self._scene.hidden {
//                        selectedImage = selectedImage?.applyDarkEffect()
//                    }
//                    if let selectedImg = selectedImage {
//                        self._selectedImage  = selectedImg
//                        if self._image != nil {
//                            self.map = mapView
//                            mapView.markers.append(self)
//                            
//                            if selected {
//                                self.setSelected()
//                            } else {
//                                self.setNotSelected()
//                            }
//                        }
//                    }
//                }
//            }
//        }
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
