//
//  StoryTellerMenuViewController.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 7/5/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//

import UIKit

class StoryTellerMenuViewController: UIViewController {
    let partyService: PartyService = Injector.sharedInjector.getPartyService()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        addBackButton()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func goBack(){
        dismissViewControllerAnimated(true, completion: {})
    }
    
    @IBAction func leaveParty(sender: AnyObject) {
        partyService.leaveParty({
            self.performSegueWithIdentifier("StoryTellerMenuToHome", sender: nil)
        })
    }
    
    func addBackButton() {
        let button   = UIButton()
        button.frame = CGRectMake(50, 25, 100, 50)
        button.backgroundColor = Colors.basePurple
        button.setTitle("Back", forState: UIControlState.Normal)
        button.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        button.addTarget(self, action: #selector(goBack), forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(button)
    }

}
