//
//  CardViewController.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 12/21/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//

import UIKit

class CardViewController: UIViewController, ProfileViewCreator {
    
    private let partyService = Services.shared.getPartyService()
    
    var cardView: DefaultCardDetailsView!
    var delegate: TripDetailsViewController!
    
    func bindContext(card: Card, owner: User, scene: Scene, blurApplies: Bool) {
        addCardView(card: card, owner: owner, scene: scene, blurApplies: blurApplies)
    }
    
    func addCardView(card: Card, owner: User, scene: Scene, blurApplies: Bool) {
        cardView = DefaultCardDetailsView.fromNib("DefaultCardDetailsView")
        cardView.initFrom(card: card, blur: 1.0 - scene.percentDiscovered, blurApplies: blurApplies)
        cardView.frame = self.view.frame
        cardView.delegate = self
        view.addSubview(cardView)
    }

    func createProfileView(_ userId: Int) {
        delegate.createProfileView(userId)
    }
    
    func setBottomViewHeight(newHeight: CGFloat) {
        cardView.setBottomViewHeight(newHeight: newHeight)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
