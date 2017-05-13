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
    
    var tripId: Int = 0
    
    var startPartyButton: UIButton?
    
    func bindContext(card: Card, owner: User, scene: Scene) {
        tripId = scene.tripId
        addCardView(card: card, owner: owner, scene: scene)
        addStartPartyButton()
    }
    
    func addCardView(card: Card, owner: User, scene: Scene) {
        cardView = DefaultCardDetailsView.fromNib("DefaultCardDetailsView")
        cardView.initFrom(card: card, hidden: scene.hidden, blur: scene.blur)
        cardView.frame = self.view.frame
        cardView.delegate = self
        view.addSubview(cardView)
    }
    
    func addStartPartyButton() {
        startPartyButton = UIButton()
        startPartyButton?.backgroundColor = .basePurple
        startPartyButton?.frame = CGRect(x: view.frame.width / 2 - 70, y: view.frame.height  - 160, width: 140, height: 40)
        startPartyButton?.setTitle("CREATE PARTY", for: .normal)
        startPartyButton?.setTitleColor(.white, for: .normal)
        startPartyButton?.addTarget(self, action: #selector(goOnTrip), for: .touchUpInside)
        view.addSubview(startPartyButton!)
        view.bringSubview(toFront: startPartyButton!)
    }
    
    func goOnTrip(_ sender: UIButton) {
        sender.isEnabled = false
        partyService.createParty(tripId, callback: self.onPartyCreated)
    }

    
    func createProfileView(_ userId: Int) {
        delegate.createProfileView(userId)
    }
    
    func setBottomViewHeight(newHeight: CGFloat) {
        cardView.setBottomViewHeight(newHeight: newHeight)
    }
    
    func onPartyCreated() {
        delegate.onPartyCreated()
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
