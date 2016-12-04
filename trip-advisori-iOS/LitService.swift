//
//  LitService.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 10/8/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//

import UIKit

enum Litness {
    case lit, notLit
}

class LitService: Service {
    
    private let _apiAmbassador:AmbassadorToTheAPI
    private let _currentLocationService: CurrentLocationService
    private var _litness: Litness
    
    init(apiAmbassador: AmbassadorToTheAPI, currentLocationService: CurrentLocationService){
        _apiAmbassador = apiAmbassador
        _currentLocationService = currentLocationService
        _litness = Litness.notLit
    }
    
    func light(successCallback: @escaping () -> Void) {
        let location = [
            "Latitude": _currentLocationService.latitude,
            "Longitude": _currentLocationService.longitude
        ]
        
        _apiAmbassador.post(apiURL + "/light", parameters: location as [String : AnyObject], success: { response in
            self.toggleLitness()
            successCallback()
        })
    }
    
    func extinguish(successCallback: @escaping () -> Void) {
        let location = [
            "Latitude": _currentLocationService.latitude,
            "Longitude": _currentLocationService.longitude
        ]
        
        _apiAmbassador.post(apiURL + "/extinguish", parameters: location as [String : AnyObject], success: { response in
            self.toggleLitness()
            successCallback()
        })
    }
    
    func toggleLitness() {
        _litness = isLit ? .notLit : .lit
    }
    
    func setLitness(lit: Bool) {
        _litness = lit ? .lit : .notLit
    }
    
    var isLit: Bool {
        get {
            return _litness == .lit
        }
    }
    
    
}
