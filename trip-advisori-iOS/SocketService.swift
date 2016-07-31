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
    func onResponseRecieved(_partyState_: PartyState) -> Void
}

class SocketService: Service, WebSocketDelegate, CurrentLocationServiceDelegate {
    private var socket: WebSocket!
    var authService: AuthService!
    var headers:Dictionary<String, String>!
    var currentLocation: CurrentLocationService!
    var delegate:SocketServiceDelegate!
    
    init(_authService_: AuthService, _currentLocation_: CurrentLocationService) {
        super.init()
        currentLocation = _currentLocation_
        authService = _authService_
        
        currentLocation.delegate = self
        
        openSocket()
    }
    
    private func setSocketHeaders() {
        let token = authService.getToken()
        
        let headers = [
            "Authorization": "bearer \(token)"
        ]
        
        socket.headers = headers
    }
    
    func openSocket() {
        socket = WebSocket(url: NSURL(string: "\(wsURL)/pull")!, protocols: ["chat", "superchat"])
        socket.delegate = self
        socket.voipEnabled = true
        setSocketHeaders()
        socket.connect()
    }
        
    func websocketDidConnect(ws: WebSocket) {
        updateLocation()
    }
    
    func updateLocation() {
        let location:Location = currentLocation.location
        let jsonLocation = Mapper().toJSONString(location, prettyPrint: true)
        if socket != nil {
            socket.writeString(jsonLocation!)
        }
    }
    
    func websocketDidDisconnect(ws: WebSocket, error: NSError?) {
        if let e = error {
            print("websocket is disconnected: \(e.localizedDescription)")
        } else {
            openSocket()
        }
    }
    
    func onLocationUpdated() {
        updateLocation()
    }
    
    func websocketDidReceiveMessage(ws: WebSocket, text: String) {
        if let partyState:PartyState = Mapper<PartyState>().map(text) {
            if delegate != nil {
                delegate.onResponseRecieved(partyState)
            }
        }
    }
    
    func websocketDidReceiveData(ws: WebSocket, data: NSData) {
        print("Received data: \(data.length)")
    }
    
    func createNoSocketWarning() {
        let label = UILabel(frame: CGRectMake(0, 0, 200, 40))
        label.center = CGPointMake(200, 580)
        label.textAlignment = NSTextAlignment.Center
        label.text = "No Socket"
        label.font = UIFont(name: Fonts.dosisBold, size: 16)
        label.textColor = UIColor.whiteColor()
        label.backgroundColor = Colors.basePurple
        UIApplication.topViewController()!.view.addSubview(label)
    }
}
