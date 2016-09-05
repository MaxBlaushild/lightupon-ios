
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
    private let _authService:AuthService
    
    internal typealias NetworkSuccessHandler = (Response<AnyObject, NSError>) -> Void
    internal typealias NetworkFailureHandler = (NSHTTPURLResponse?, AnyObject?, NSError) -> Void
    internal typealias Header = (Dictionary<String, String>)
    
    private typealias QueuedRequest = (NSHTTPURLResponse?, AnyObject?, NSError?) -> Void

    private var RequestQueue = Array<QueuedRequest>()
    private var isRefreshing = false

    var headers:Dictionary<String, String>?
    
    init(authService: AuthService) {
        _authService = authService
        
        super.init()

        setHeaders()
    }
    
    private func setHeaders() {
        let token = _authService.getToken()
        
        let headers = [
            "Authorization": "bearer \(token)"
        ]
        
        self.headers = headers
    }

    func get(URLString: URLStringConvertible, success: NetworkSuccessHandler?) {
        setHeaders()
        Alamofire.request(.GET, URLString, headers: headers).responseJSON { response in
            self.processResponse(response, success: success!, URLString: URLString)
        }
            
    }
    
    func post(URLString: URLStringConvertible, parameters:[String:AnyObject], success: NetworkSuccessHandler?) {
        setHeaders()
        Alamofire.request(.POST, URLString, parameters: parameters, headers: headers, encoding: .JSON).responseJSON { response in
            self.processResponse(response, success: success!, URLString: URLString)
        }
        
    }
    
    func delete(URLString: URLStringConvertible, success: NetworkSuccessHandler?) {
        setHeaders()
        Alamofire.request(.DELETE, URLString, headers: headers, encoding: .JSON).responseJSON { response in
            self.processResponse(response, success: success!, URLString: URLString)
        }
    }
    
    func processResponse(response: Response<AnyObject, NSError>, success: NetworkSuccessHandler, URLString: URLStringConvertible) {
        if response.result.isFailure {
            if response.response!.statusCode == 401 {
                self.refreshToken(URLString, success: success)
            } else {
                createNoInternetWarning()
            }
        }  else {
            success(response)
        }
    }
    
    func createNoInternetWarning() {
        let topView = UIApplication.topViewController()!.view
        let label = UILabel(frame: CGRectMake(0, topView.frame.height - 40, topView.frame.width, 40))
        label.textAlignment = NSTextAlignment.Center
        label.text = "No Internet Connectivity"
        label.font = UIFont(name: Fonts.dosisBold, size: 16)
        label.textColor = UIColor.whiteColor()
        label.backgroundColor = Colors.basePurple
        topView.addSubview(label)
    }
    
    private func refreshToken(URLString: URLStringConvertible, success: NetworkSuccessHandler?) {
        let facebookId:String = _authService.getFacebookId()
        Alamofire.request(.PATCH, apiURL + "/users/\(facebookId)/token")
            .responseJSON { response in
                let json = JSON(response.result.value!)
                let token:String = json.string!
                self._authService.setToken(token)
                self.setHeaders()
                self.get(URLString, success: success)
        }
    }

}