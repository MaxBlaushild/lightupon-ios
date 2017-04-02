//
//  JoinPartyAPIController.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 3/25/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//

import UIKit
import ObjectMapper

@objc protocol PartyServiceDelegate {
    @objc optional func onNextScene(_ scene: Scene) -> Void
    @objc optional func onNextSceneAvailableUpdated(_ nextSceneAvailable: Bool) -> Void
}

class PartyService: NSObject, SocketServiceDelegate {
    
    private let _apiAmbassador:AmbassadorToTheAPI
    private let _socketService:SocketService
    
    private var _partyServiceDelegates: [PartyServiceDelegate] = [PartyServiceDelegate]()
    
    public var currentParty: Party?
    
    private var nextSceneAvailable: Bool = false
    
    init(apiAmbassador: AmbassadorToTheAPI, socketService: SocketService){
        _apiAmbassador = apiAmbassador
        _socketService = socketService
        
        super.init()
        
        _socketService.registerDelegate(self)
    }
    
    func registerDelegate(_ partyServiceDelegate: PartyServiceDelegate) {
        _partyServiceDelegates.append(partyServiceDelegate)
    }
    
    func currentScene() -> Scene? {
        if let party = currentParty {
            if let trip = party.trip {
                if let sceneOrder = party.currentSceneOrder {
                    return trip.getSceneWithOrder(sceneOrder + 1)
                }
            }
        }
        return nil
    }
    
    func nextScene() -> Scene? {
        if let party = currentParty {
            if let trip = party.trip {
                if let sceneOrder = party.currentSceneOrder {
                    return trip.getSceneWithOrder(sceneOrder + 2)
                }
            }
        }
        return nil
    }
    
    func endOfTrip() -> Bool {
        if let party = currentParty {
            if party.currentSceneOrder! >= party.trip!.scenes.count - 1 {
                return true
            }
        }
        return false
    }
    
    func updateDelegatesOnSceneAvailability() {
        _partyServiceDelegates.forEach({ delegate in
            delegate.onNextSceneAvailableUpdated?(nextSceneAvailable)
        })
    }
    
    func updateDelegatesOnNextScene() {
        _partyServiceDelegates.forEach({ delegate in
            delegate.onNextScene?(currentParty!.currentScene)
        })
    }
    
    func onResponseReceived(_ partyState: PartyState) {
        nextSceneAvailable = partyState.nextSceneAvailable ?? false
        updateDelegatesOnSceneAvailability()
        
        if currentParty?.currentSceneOrder != partyState.currentSceneOrder {
            currentParty?.currentSceneOrder = partyState.currentSceneOrder
            updateDelegatesOnNextScene()
        }
    }
    
    func joinParty(passcode: String, successCallback: @escaping () -> Void, failureCallback: @escaping () -> Void) {
        let parameters = [
            "": ""
        ]
        
        _apiAmbassador.post("/parties/\(passcode)/users", parameters: parameters as [String : AnyObject], success: { response in
            if (response.response!.statusCode == 200) {
                successCallback()
            } else {
                failureCallback()
            }
        })
    }
    
    func startNextScene() {
        if let party = currentParty {
            _apiAmbassador.get("/parties/\(party.id ?? 0)/nextScene", success: { _ in
            })
        }
     }
    
    func getUsersParty(_ callback: @escaping (Party?) -> Void) {
        _apiAmbassador.get("/parties", success: { response in
            let party = Mapper<Party>().map(JSONObject: response.result.value)
            if party?.id != 0 {
                self.currentParty = party
                callback(party)
            } else {
                callback(nil)
            }
        })
    }
    
    func leaveParty(_ callback: @escaping () -> Void) {
        _apiAmbassador.delete("/parties", success: { response in
            callback()
        })
    }
    
    func end(callback: @escaping () -> Void) {
        if let party = currentParty {
            _apiAmbassador.get("/parties/\(party.id ?? 0)/end", success: { response in
                callback()
            })
        }
    }
    
    func createParty(_ tripId: Int, callback: @escaping () -> Void) {
        let parameters = [
            "ID": tripId
        ]
        
        _apiAmbassador.post("/parties", parameters: parameters as [String : AnyObject], success: { response in
            callback()
        })
    }
}
