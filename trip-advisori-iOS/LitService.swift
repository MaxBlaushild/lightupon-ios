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

class LitService: NSObject {
    
    private let _apiAmbassador:AmbassadorToTheAPI
    private let _currentLocationService: CurrentLocationService
    private var _litness: Litness
    
    public let litStatusChangeNotificationName = Notification.Name("OnLitStatusChange")
    
    init(apiAmbassador: AmbassadorToTheAPI, currentLocationService: CurrentLocationService){
        _apiAmbassador = apiAmbassador
        _currentLocationService = currentLocationService
        _litness = Litness.notLit
    }
    
    func light(successCallback: @escaping () -> Void) {
        _apiAmbassador.post("/light", parameters: ["":"" as AnyObject], success: { response in
            self.toggleLitness()
            NotificationCenter.default.post(name: self.litStatusChangeNotificationName, object: nil)
            successCallback()
        })
    }
    
    func extinguish(successCallback: @escaping () -> Void) {
        _apiAmbassador.post("/extinguish", parameters: ["":"" as AnyObject], success: { response in
            self.toggleLitness()
            NotificationCenter.default.post(name: self.litStatusChangeNotificationName, object: nil)
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
