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
                
            if response!.statusCode == 401 {
                self.refreshToken(URLString, success: success)
            } else {
                success!(request, response, result)
            }
        }
            
    }
    
    func post(URLString: URLStringConvertible, parameters:[String:AnyObject], success: NetworkSuccessHandler?) {
        setHeaders()
        Alamofire.request(.POST, URLString, parameters: parameters, headers: headers, encoding: .JSON).responseJSON { request, response, result in
            
            if response!.statusCode == 401 {
                self.refreshToken(URLString, success: success)
            } else {
                success!(request, response, result)
            }
        }
        
    }
    
    func delete(URLString: URLStringConvertible, success: NetworkSuccessHandler?) {
        setHeaders()
        Alamofire.request(.POST, URLString, headers: headers, encoding: .JSON).responseJSON { request, response, result in
            
            if response!.statusCode == 401 {
                self.refreshToken(URLString, success: success)
            } else {
                success!(request, response, result)
            }
        }
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