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
    private var _litness: Litness
    
    init(apiAmbassador: AmbassadorToTheAPI){
        _apiAmbassador = apiAmbassador
        _litness = Litness.notLit
    }
    
    func light(successCallback: @escaping () -> Void) {
        let parameters = ["": ""]
        
        _apiAmbassador.post(apiURL + "/light", parameters: parameters as [String : AnyObject], success: { response in
            self.toggleLitness()
            successCallback()
        })
    }
    
    func extinguish(successCallback: @escaping () -> Void) {
        let parameters = ["": ""]
        
        _apiAmbassador.post(apiURL + "/extinguish", parameters: parameters as [String : AnyObject], success: { response in
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
