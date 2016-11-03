//
//  TripService.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 4/9/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//

import UIKit
import Foundation
import Starscream
import ObjectMapper
import SwiftyJSON

protocol SocketServiceDelegate {
    func onResponseReceived(_ _partyState_: PartyState) -> Void
}

class SocketService: Service, WebSocketDelegate, CurrentLocationServiceDelegate {
    
    fileprivate let _authService: AuthService
    fileprivate let _currentLocationService: CurrentLocationService
    
    fileprivate var _socketPolling: Timer!
    fileprivate var _socket: WebSocket!

    internal var delegates:[SocketServiceDelegate] = [SocketServiceDelegate]()
    
    init(authService: AuthService, currentLocationService: CurrentLocationService) {
        _currentLocationService = currentLocationService
        _authService = authService
        
        super.init()
        
        _currentLocationService.registerDelegate(self)
            
        openSocket()
        keepSocketOpen()
    }
    
    func openSocket() {
        _socket = WebSocket(url: URL(string: "\(wsURL)/pull")!, protocols: ["chat", "superchat"])
        _socket.delegate = self
        _socket.voipEnabled = true
        setSocketHeaders()
        _socket.connect()
    }
    
    func keepSocketOpen() {
        _socketPolling = Timer.scheduledTimer(timeInterval: 3.0,
            target: self,
            selector: #selector(SocketService.checkOnSocket),
            userInfo: nil,
            repeats: true
        )
    }
    
    fileprivate func setSocketHeaders() {
        let token = _authService.getToken()
        
        _socket.headers = [
            "Authorization": "bearer \(token)"
        ]
    }
    
    func registerDelegate(_ delegate: SocketServiceDelegate) {
        delegates.append(delegate)
    }
    
    func onHeadingUpdated() {}
        
    func websocketDidConnect(socket ws: WebSocket) {
        updateLocation()
    }
    
    func checkOnSocket() {
        if !_socket.isConnected {
            setSocketHeaders()
            _socket.connect()
        }
    }
    
    func updateLocation() {
        if (_authService.userIsLoggedIn()) {
            if (_currentLocationService.hasRecievedLocation) {
                let location:Location = _currentLocationService.location
                let jsonLocation = Mapper().toJSONString(location, prettyPrint: true)
                _socket.write(string: jsonLocation!)
            }
        }
    }
    
    func websocketDidDisconnect(socket ws: WebSocket, error: NSError?) {
        if let e = error {
            print("websocket is disconnected: \(e.localizedDescription)")
        } else {
            openSocket()
        }
    }
    
    func onLocationUpdated() {
        updateLocation()
    }
    
    func websocketDidReceiveMessage(socket ws: WebSocket, text: String) {
        
        if let partyState:PartyState = Mapper<PartyState>().map(JSONString: text) {
            for delegate in delegates {
                delegate.onResponseReceived(partyState)
            }
        }
    }
    
    func websocketDidReceiveData(socket ws: WebSocket, data: Data) {}
}
