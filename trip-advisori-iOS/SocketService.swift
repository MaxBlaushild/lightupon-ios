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

@objc protocol SocketServiceDelegate {
    @objc optional func onResponseReceived(socketResponse: SocketResponse) -> Void
    @objc optional func onSceneUpdated(sceneID: Int) -> Void
}

class SocketService: NSObject, WebSocketDelegate, CurrentLocationServiceDelegate {
    private let _authService: AuthService
    private let _currentLocationService: CurrentLocationService
    
    fileprivate var _socketPolling: Timer!
    fileprivate var _socket: WebSocket!

    internal var delegates:[SocketServiceDelegate] = [SocketServiceDelegate]()
    
    init(authService: AuthService, currentLocationService: CurrentLocationService) {
        _authService = authService
        _currentLocationService = currentLocationService
        
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
    
    func updateLocation() {
        let location:Location = _currentLocationService.location
        let jsonLocation = Mapper().toJSONString(location, prettyPrint: true)
        if _socket != nil {
            _socket.write(string: jsonLocation!)
        }
    }
    
    func websocketDidConnect(ws: WebSocket) {
        updateLocation()
    }
    
    func onLocationUpdated() {
        updateLocation()
    }
    
    func pokeSocket() {
        updateLocation()
    }
    
    fileprivate func setSocketHeaders() {
        let token = _authService.getToken()

        _socket.headers = [
            "Authorization": "Bearer \(token)"
        ]
    }
    
    func registerDelegate(_ delegate: SocketServiceDelegate) {
        delegates.append(delegate)
    }
        
    func websocketDidConnect(socket ws: WebSocket) {}
    
    func checkOnSocket() {
        if !_socket.isConnected {
            setSocketHeaders()
            _socket.connect()
        } else {
            updateLocation()
        }
    }
    
    func websocketDidDisconnect(socket ws: WebSocket, error: NSError?) {
        if let e = error {
            print("websocket is disconnected: \(e.localizedDescription)")
        } else {
            openSocket()
        }
    }
    
    func websocketDidReceiveMessage(socket ws: WebSocket, text: String) {
        if let socketResponse:SocketResponse = Mapper<SocketResponse>().map(JSONString: text) {
            for delegate in delegates {
                delegate.onResponseReceived?(socketResponse: socketResponse)
                if socketResponse.updatedSceneID != 0 {
                    delegate.onSceneUpdated?(sceneID: socketResponse.updatedSceneID)
                }
            }
        }
    }
    
    func websocketDidReceiveData(socket ws: WebSocket, data: Data) {}
}
