//
//  MenuViewController.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 6/7/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func addTitle(title: String, color: UIColor) {
        let label = UILabel(frame: CGRectMake(0, 0, 200, 40))
        label.center = CGPointMake(100, 50)
        label.textAlignment = NSTextAlignment.Center
        label.text = title
        label.font = UIFont(name: Fonts.dosisExtraLight, size: 38)
        label.textColor = color
        self.view.addSubview(label)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
