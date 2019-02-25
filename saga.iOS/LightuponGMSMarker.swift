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
    
    var _post: Post
    var _image: UIImage?
    var _selectedImage: UIImage?
    var _selected: Bool = false
    
    init(post: Post) {
        _post = post
        super.init()
        position = CLLocationCoordinate2DMake(post.latitude ?? 0.0, post.longitude ?? 0.0)
        title = post.name
        userData = post
         NotificationCenter.default.addObserver(self, selector: #selector(onPostUpdated), name: feedService.sceneUpdatedSubscriptionName, object: nil)
    }
    
    func onPostUpdated(notification: NSNotification) {
        let postID = notification.object as! Int
        if postID == _post.id {
            self.feedService.getPost(postID, success: { post in
                self._post = post
                self.updateImages()
            })
        }
    }
    
    func setImages(mapView: LightuponGMSMapView, selected: Bool) {
        if let pinUrl = _post.pin!.url {
            Alamofire.request(pinUrl).responseJSON { response in
                if let data = response.data {
                    let image = UIImage(data: data)
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
    
    func updateImages() {
        _image = nil
        _selectedImage = nil
        let backgroundQueue = DispatchQueue.global(qos: .background)
        
        if let pinUrl = _post.pin!.url {
            Alamofire.request(pinUrl).responseJSON(queue: backgroundQueue) { response in
                if let data = response.data {
                    let image = UIImage(data: data)
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
    
    var post: Post {
        get {
            return _post
        }
    }
    
    var cllocation: CLLocation {
        get {
            return CLLocation(latitude: _post.latitude!, longitude: _post.longitude!)
        }
    }
}
