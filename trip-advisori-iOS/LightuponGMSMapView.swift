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

let selectedZoom: Float = 15.0

class LightuponGMSMapView: GMSMapView {
    let googleMapsService = Injector.sharedInjector.getGoogleMapsService()
    
    var markers = [LightuponGMSMarker]()
    var directions: [GMSPolyline] = [GMSPolyline]()
    var selectedLightuponMarker: LightuponGMSMarker?
    
    func bindTrips(_ trips: [Trip]) {
        clearMarkers()
        for trip in trips {
            placeTripOnMap(trip)
        }
    }
    
    func bindTrip(_ trip: Trip) {
        placeTripOnMap(trip)
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
        singleLine.strokeColor = Colors.basePurple
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
                googleMapsService.getDirections(origin: currentScene.location, destination: nextScene.location, callback: { path in
                    self.drawLine(path)
                })
            }
        }
    }

    
    private func placeTripOnMap(_ trip: Trip) {
        placeMarkers(trip: trip)
    }
    
    private func placeMarkers(trip: Trip) {
        for scene in trip.scenes {
            scene.trip = trip
            placeMarker(scene: scene)
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
        if selectedLightuponMarker != nil {
            selectedLightuponMarker?.setNotSelected()
        }
        
        marker.setSelected()
        selectedLightuponMarker = marker
        clearDirections()
        updateFrame()
        drawDirections()
    }
    
    func findOrCreateMarker(byScene scene: Scene)  -> LightuponGMSMarker? {
        let marker = markers.first(where:{$0.scene.id == scene.id})
        return marker == nil ? createMarkerSync(scene: scene) : marker
    }
    
    private func createMarkerSync(scene: Scene) -> LightuponGMSMarker {
        let marker = LightuponGMSMarker(scene: scene)
        marker.setImages(scene.image!, map: self)
        marker.setSelected()
        marker.map = self
        return marker
        
    }
    
    private func placeMarker(scene: Scene) {
        Alamofire.request(scene.backgroundUrl!, method: .get, parameters: nil).responseJSON { (response) in
            let image = response.response!.statusCode == 200 ? UIImage(data: response.data!, scale: 1) : UIImage(named: "banner")
            let marker = LightuponGMSMarker(scene: scene)
            DispatchQueue.global(qos: .background).async {
                marker.setImages(image!, map: self)
                DispatchQueue.main.async {
                    self.markers.append(marker)
                    marker.setNotSelected()
                    marker.map = self
                }
            }
        }
    }

}
