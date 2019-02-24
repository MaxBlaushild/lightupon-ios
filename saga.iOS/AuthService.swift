//
//  AuthService.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 2/15/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//

import UIKit
import Locksmith
import FBSDKLoginKit
import Alamofire

class AuthService: NSObject {
    
    func setToken(_ token: String) {
        
        do {
            
            try Locksmith.updateData(data: ["token": token], forUserAccount: "myUserAccount")
            
        } catch {
            
            print("whoops!")
            
        }
    }
    
    func setFacebookId(_ facebookId: String) {
        
        do {
            
            try Locksmith.updateData(data: ["facebookId": facebookId], forUserAccount: "myFacebookAccount")
            
        } catch {
            
            print("whoops!")
            
        }
    }
    
    func getToken() -> String {
        var token = ""
        
        if let tokenWrapper = Locksmith.loadDataForUserAccount(userAccount: "myUserAccount") as? Dictionary<String, String> {
            token = tokenWrapper["token"]!
        }

        return token
    }
    
    func logout() {
        deleteToken()
        FBSDKLoginManager().logOut()
    }
    
    func deleteToken() {
        
        do {
            
            try Locksmith.deleteDataForUserAccount(userAccount: "myUserAccount")
            
        } catch {
            
        }
    }
    
    func getFacebookId() -> String {
        let idWrapper = Locksmith.loadDataForUserAccount(userAccount: "myFacebookAccount")!
        
        let facebookId = idWrapper["facebookId"] as! String
        
        return facebookId
    }
    
    func userIsLoggedIn() -> Bool {
        
        let token = Locksmith.loadDataForUserAccount(userAccount: "myUserAccount")
        
        if token != nil && FBSDKAccessToken.current() != nil {
            return true
        } else {
            return false
        }
    }
    
    deinit {
        print("i am dead")
    }

}
