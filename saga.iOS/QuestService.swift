//
//  QuestService.swift
//  Saga
//
//  Created by Max Blaushild on 3/2/19.
//  Copyright © 2019 Blaushild, Max. All rights reserved.
//

import Foundation
import Promises
import ObjectMapper

class QuestService: NSObject {
    
    private let _apiAmbassador:AmbassadorToTheAPI
    
    init(apiAmbassador: AmbassadorToTheAPI) {
        _apiAmbassador = apiAmbassador
    }
    
    func getActiveQuests() -> Promise<[Quest]> {
        return Promise<[Quest]> { fulfill, reject in
            self._apiAmbassador.get("/quests/active", success: { response in
                let quests = Mapper<Quest>().mapArray(JSONObject: response.result.value) ?? [Quest]()
                fulfill(quests)
            })
        }
    }
}
