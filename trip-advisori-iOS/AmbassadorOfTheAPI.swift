//
//  AmbassadorOfTheAPI.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 2/28/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//

import UIKit
import Foundation
import Alamofire
import SwiftyJSON

class AmbassadorToTheAPI: Service {
    internal typealias NetworkSuccessHandler = (NSURLRequest?, NSHTTPURLResponse?, Result<AnyObject>?) -> Void
    internal typealias NetworkFailureHandler = (NSHTTPURLResponse?, AnyObject?, NSError) -> Void
    internal typealias Header = (Dictionary<String, String>)
    
    private typealias QueuedRequest = (NSHTTPURLResponse?, AnyObject?, NSError?) -> Void

    private var RequestQueue = Array<QueuedRequest>()
    private var isRefreshing = false
    private var authService:AuthService!
    var headers:Dictionary<String, String>?
    
    init(_authService_: AuthService) {
        super.init()
        authService = _authService_
        setHeaders()
    }
    
    private func setHeaders() {
        let token = authService.getToken()
        
        let headers = [
            "Authorization": "bearer \(token)"
        ]
        
        self.headers = headers
    }

    func get(URLString: URLStringConvertible, success: NetworkSuccessHandler?) {
        setHeaders()
        Alamofire.request(.GET, URLString, headers: headers).responseJSON { request, response, result in
            self.processResponse(request, response: response, result: result, success: success!, URLString: URLString)
        }
            
    }
    
    func post(URLString: URLStringConvertible, parameters:[String:AnyObject], success: NetworkSuccessHandler?) {
        setHeaders()
        Alamofire.request(.POST, URLString, parameters: parameters, headers: headers, encoding: .JSON).responseJSON { request, response, result in
            self.processResponse(request, response: response!, result: result, success: success!, URLString: URLString)
        }
        
    }
    
    func delete(URLString: URLStringConvertible, success: NetworkSuccessHandler?) {
        setHeaders()
        Alamofire.request(.POST, URLString, headers: headers, encoding: .JSON).responseJSON { request, response, result in
            self.processResponse(request, response: response!, result: result, success: success!, URLString: URLString)
        }
    }
    
    func processResponse(request: NSURLRequest?, response: NSHTTPURLResponse?, result: Result<AnyObject>, success: NetworkSuccessHandler, URLString: URLStringConvertible) {
        if result.isFailure {
            createNoInternetWarning()
        } else if response!.statusCode == 401 {
            self.refreshToken(URLString, success: success)
        } else {
            success(request, response, result)
        }
    }
    
    func createNoInternetWarning() {
        let label = UILabel(frame: CGRectMake(0, 0, 200, 40))
        label.center = CGPointMake(200, 580)
        label.textAlignment = NSTextAlignment.Center
        label.text = "No Internet Connectivity"
        label.font = UIFont(name: Fonts.dosisBold, size: 16)
        label.textColor = UIColor.whiteColor()
        label.backgroundColor = Colors.basePurple
        UIApplication.topViewController()!.view.addSubview(label)
    }
    
    private func refreshToken(URLString: URLStringConvertible, success: NetworkSuccessHandler?) {
        let facebookId:String = authService.getFacebookId()
        Alamofire.request(.PATCH, apiURL + "/users/\(facebookId)/token")
            .responseJSON { request, response, result in
                let json = JSON(result.value!)
                let token:String = json.string!
                self.authService.setToken(token)
                self.setHeaders()
                self.get(URLString, success: success)
        }
    }

}