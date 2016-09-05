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
    func onResponseReceived(_partyState_: PartyState) -> Void
}

class SocketService: Service, WebSocketDelegate, CurrentLocationServiceDelegate {
    private let _authService: AuthService
    private let _currentLocationService: CurrentLocationService
    
    private var _socket: WebSocket!

    internal var delegates:[SocketServiceDelegate] = [SocketServiceDelegate]()
    
    init(authService: AuthService, currentLocationService: CurrentLocationService) {
        
        _currentLocationService = currentLocationService
        _authService = authService
        
        super.init()
        
        _currentLocationService.registerDelegate(self)
        
        openSocket()
    }
    
    private func setSocketHeaders() {
        let token = _authService.getToken()
        
        _socket.headers = [
            "Authorization": "bearer \(token)"
        ]
    }
    
    func registerDelegate(delegate: SocketServiceDelegate) {
        delegates.append(delegate)
    }
    
    func onHeadingUpdated() {}
    
    func openSocket() {
        _socket = WebSocket(url: NSURL(string: "\(wsURL)/pull")!, protocols: ["chat", "superchat"])
        _socket.delegate = self
        _socket.voipEnabled = true
        setSocketHeaders()
        _socket.connect()
    }
        
    func websocketDidConnect(ws: WebSocket) {
        updateLocation()
    }
    
    func pokeSocket() {
        updateLocation()
    }
    
    func updateLocation() {
        let location:Location = _currentLocationService.location
        let jsonLocation = Mapper().toJSONString(location, prettyPrint: true)
        _socket.writeString(jsonLocation!)
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
            for delegate in delegates {
                delegate.onResponseReceived(partyState)
            }
        }
    }
    
    func websocketDidReceiveData(ws: WebSocket, data: NSData) {
        print("Received data: \(data.length)")
    }
}
