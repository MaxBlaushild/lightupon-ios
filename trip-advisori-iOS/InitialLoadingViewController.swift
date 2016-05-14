//
//  InitialLoadingViewController.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 2/1/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//

import UIKit

class InitialLoadingViewController: UIViewController {
    private let contentLoaderService:ContentLoaderService = Injector.sharedInjector.getContentLoaderService()
    @IBOutlet weak var loadingLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        contentLoaderService.loadContent(self.routeTo)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func routeTo(segue: String){
        dispatch_async(dispatch_get_main_queue()){
            self.performSegueWithIdentifier(segue, sender: nil)
        }
    }
}
