//
//  CardViewController.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 12/21/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//

import UIKit

class CardViewController: UIViewController, ProfileViewCreator {
    
    var cardView: DefaultCardDetailsView!
    var delegate: ProfileViewCreator!
    
    func bindContext(card: Card, owner: User, scene: Scene) {
        cardView = DefaultCardDetailsView.fromNib("DefaultCardDetailsView")
        cardView.initFrom(card: card, owner: owner, scene: scene)
        cardView.frame = self.view.frame
        cardView.delegate = self
        self.view.addSubview(cardView)
    }
    
    func createProfileView(user: User) {
        delegate.createProfileView(user: user)
    }
    
    func setBottomViewHeight(newHeight: CGFloat) {
        cardView.setBottomViewHeight(newHeight: newHeight)
    }
    
    func onPartyCreated() {
        performSegue(withIdentifier: "CardToMain", sender: self)
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
