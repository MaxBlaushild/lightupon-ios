//
//  NotSelectingViewController.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 1/19/17.
//  Copyright © 2017 Blaushild, Max. All rights reserved.
//

import UIKit

class NotSelectingViewController: UIViewController {
    
    var doNotSelectMe:String!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        doNotSelectMe = "forTheLoveOfGodDontSelectMe"
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
