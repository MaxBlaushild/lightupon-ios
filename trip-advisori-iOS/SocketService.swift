//
//  TripService.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 4/9/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//

import UIKit
import Starscream
import ObjectMapper
import SwiftyJSON

protocol SocketServiceDelegate {
    func openAlert(title: String, message: String)
}

class SocketService: Service, WebSocketDelegate {
    private var socket: WebSocket!
    var authService: AuthService!
    var headers:Dictionary<String, String>!
    var currentLocation: CurrentLocationService!
    var delegate:SocketServiceDelegate!
    
    init(_authService_: AuthService, _currentLocation_: CurrentLocationService) {
        super.init()
        currentLocation = _currentLocation_
        authService = _authService_
    }
    
    private func setSocketHeaders() {
        let token = authService.getToken()
        
        let headers = [
            "Authorization": "bearer \(token)"
        ]
        
        socket.headers = headers
    }
    
    func openSocket(passcode: String) {
        socket = WebSocket(url: NSURL(string: "\(wsURL)/parties/\(passcode)/pull")!, protocols: ["chat", "superchat"])
        socket.delegate = self
        setSocketHeaders()
        socket.connect()
    }
        
    func websocketDidConnect(ws: WebSocket) {
        updateLocation()
    }
    
    func updateLocation() {
        let location:Location = currentLocation.location
        let jsonLocation = Mapper().toJSONString(location, prettyPrint: true)
        socket.writeString(jsonLocation!)
    }
    
    func websocketDidDisconnect(ws: WebSocket, error: NSError?) {
        
        
        
        if let e = error {
            print("websocket is disconnected: \(e.localizedDescription)")
        } else {
            print("websocket disconnected")
        }
    }
    
    func websocketDidReceiveMessage(ws: WebSocket, text: String) {
        let json = JSON(text)
        
        print("Received text: \(text)")
    }
    
    func websocketDidReceiveData(ws: WebSocket, data: NSData) {
        print("Received data: \(data.length)")
    }
}
