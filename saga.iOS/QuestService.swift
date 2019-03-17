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
import Observable

struct FocusedQuest {
    var quest: Quest?
}

class QuestService: NSObject {
    
    private let _apiAmbassador:AmbassadorToTheAPI
    private let _focusedQuest = Observable<FocusedQuest>(FocusedQuest())
    
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
    
    func observeFocusChanges(_ onFocusChange: @escaping (FocusedQuest) -> ()) -> Disposable {
        return _focusedQuest.observe { f, _ in
            onFocusChange(f)
        }
    }
    
    func trackNewQuest(questID: Int) -> Promise<Void> {
        return Promise<Void> { fulfill, reject in
            self._apiAmbassador.post("/quests/\(questID)/track", parameters: [:], success: { response in
                self._apiAmbassador.get("/quests/\(questID)", success: { response in
                    if let quest = Mapper<Quest>().map(JSONObject: response.result.value) {
                        self.focusOnQuest(quest)
                        fulfill()
                    }
                })
            })
        }
    }
    
    func dropQuestFocus() {
        let newFocusedQuest = FocusedQuest()
        _focusedQuest.value = newFocusedQuest
    }
    
    func focusOnQuest(_ quest: Quest) {
        var newFocusedQuest = FocusedQuest()
        newFocusedQuest.quest = quest
        _focusedQuest.value = newFocusedQuest
    }
}
