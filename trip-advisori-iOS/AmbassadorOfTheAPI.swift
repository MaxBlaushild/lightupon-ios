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

let apiURL:String = "http://45.55.160.25/lightupon"
let wsURL:String = "ws://45.55.160.25/lightupon"
//let apiURL:String = "http://localhost:5000/lightupon"
//let wsURL:String = "ws://localhost:5000/lightupon"

class AmbassadorToTheAPI: NSObject {
    fileprivate let _authService:AuthService
    
    internal typealias NetworkSuccessHandler = (DataResponse<Any>) -> Void
    internal typealias NetworkFailureHandler = (DataResponse<Any>) -> Void
    internal typealias Header = (Dictionary<String, String>)
    
    fileprivate typealias QueuedRequest = (HTTPURLResponse?, AnyObject?, NSError?) -> Void

    fileprivate var RequestQueue = Array<QueuedRequest>()
    fileprivate var isRefreshing = false

    var headers:Dictionary<String, String>?
    
    init(authService: AuthService) {
        _authService = authService
        
        super.init()

        setHeaders()
    }
    
    fileprivate func setHeaders() {
        let token = _authService.getToken()
        
        let headers = [
            "Authorization": "bearer \(token)"
        ]
        
        self.headers = headers
    }

    func get(_ uri: URLConvertible, success: @escaping NetworkSuccessHandler) {
        setHeaders()
        
        Alamofire.request("\(apiURL)\(uri)", method: .get, headers: headers).responseJSON { response in
            self.processResponse(response, success: success, uri: uri)
        }
            
    }
    
    func get(_ uri: URLConvertible, queue: DispatchQueue, success: @escaping NetworkSuccessHandler) {
        setHeaders()
        
        Alamofire.request("\(apiURL)\(uri)", method: .get, headers: headers).responseJSON(queue: queue) { response in
            self.processResponse(response, success: success, uri: uri)
        }
        
    }
    
    func post(_ uri: URLConvertible, parameters:[String:AnyObject], success: @escaping NetworkSuccessHandler) {
        setHeaders()
        Alamofire.request("\(apiURL)\(uri)", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            self.processResponse(response, success: success, uri: uri)
        }
        
    }
    
    func post(_ uri: URLConvertible, parameters:[String:AnyObject], success: @escaping NetworkSuccessHandler, failure: @escaping NetworkFailureHandler) {
        setHeaders()
        Alamofire.request("\(apiURL)\(uri)", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            
            if response.result.isFailure {
                failure(response)
            } else {
                self.processResponse(response, success: success, uri: uri)
            }

        }
        
    }
    
    func patch(_ uri: URLConvertible, parameters:[String:AnyObject], success: NetworkSuccessHandler?) {
        setHeaders()
        Alamofire.request("\(apiURL)\(uri)", method: .patch, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            self.processResponse(response, success: success!, uri: uri)
        }
        
    }
    
    func delete(_ uri: URLConvertible, success: @escaping NetworkSuccessHandler) {
        setHeaders()
        Alamofire.request("\(apiURL)\(uri)", method: .delete, headers: headers).responseJSON { response in
            self.processResponse(response, success: success, uri: uri)
        }
    }
    
    func processResponse(_ response: DataResponse<Any>, success: @escaping NetworkSuccessHandler, uri: URLConvertible) {
        let status = response.response!.statusCode
        if (response.result.isFailure) && (status == 401) {
            self.refreshToken(uri, success: success)
        } else if (status / 100 != 2) {
            displayError(response)
        } else {
            success(response)
        }
    }
    
    func displayError(_ response: DataResponse<Any>) {
        let topView = UIApplication.topViewController()!.view
        let label = UILabel(frame: CGRect(x: 0, y: (topView?.frame.height)! - 40, width: (topView?.frame.width)!, height: 40))
        label.textAlignment = NSTextAlignment.center
        
        let JSON = response.result.value as! NSDictionary
        if let message = JSON["message"] {
            label.text = message as? String
        } else {
            label.text = "No Internet Connectivity"
        }
        
        label.font = UIFont(name: Fonts.dosisBold, size: 16)
        label.textColor = UIColor.white
        label.backgroundColor = UIColor.basePurple
        topView?.addSubview(label)
    }
    
    fileprivate func refreshToken(_ uri: URLConvertible, success: NetworkSuccessHandler?) {
        let facebookId:String = _authService.getFacebookId()
        Alamofire.request("\(apiURL)/users/\(facebookId)/token", method: .patch)
            .responseJSON { response in
                let json = JSON(response.result.value!)
                let token:String = json.string!
                self._authService.setToken(token)
                self.setHeaders()
                self.get(uri, success: success!)
        }
    }

}
