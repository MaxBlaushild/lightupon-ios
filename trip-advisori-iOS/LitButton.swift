//
//  LitButton.swift
//  Lightupon
//
//  Created by Blaushild, Max on 1/29/17.
//  Copyright © 2017 Blaushild, Max. All rights reserved.
//

import UIKit

class LitButton: UIButton {
    private let litService = Injector.sharedInjector.getLitService()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.makeCircle()
        self.bindLitness()
        self.addTarget(self, action: #selector(self.toggleLitness), for: .touchUpInside)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.makeCircle()
        self.bindLitness()
        self.addTarget(self, action: #selector(self.toggleLitness), for: .touchUpInside)
    }
    
    func toggleLitness(_ sender: Any) {
        litService.isLit ? extinguish() : light()
    }
    
    func light() {
        litService.light(successCallback: self.bindLitness)
    }
    
    func extinguish() {
        litService.extinguish(successCallback: self.bindLitness)
    }
    
    func bindLitness() {
        backgroundColor = litService.isLit ? UIColor.gold : Colors.basePurple
    }

}
