//
//  LitButton.swift
//  Lightupon
//
//  Created by Blaushild, Max on 1/29/17.
//  Copyright © 2017 Blaushild, Max. All rights reserved.
//

import UIKit

class LitButton: UIButton {
    private let litService = Services.shared.getLitService()
    
    var delegate: TripModalPresentingViewController?

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        bindLitness()
        listenForLitStatusChange()
        addTarget(self, action: #selector(self.toggleLitness), for: .touchUpInside)
        
    }
    
    func toggleLitness(_ sender: Any) {
        litService.isLit ? extinguish() : light()
    }
    
    func listenForLitStatusChange() {
        NotificationCenter.default.addObserver(self, selector: #selector(bindLitness), name: litService.litStatusChangeNotificationName, object: nil)
    }
    
    func light() {
        delegate?.openTripModal()
    }
    
    func extinguish() {
        litService.extinguish(successCallback: self.bindLitness)
    }
    
    func bindLitness() {
        let color = litService.isLit ? UIColor.gold : UIColor.basePurple
        setImageTint(imageName: "lit-unfilled", color: color)
    }

}
