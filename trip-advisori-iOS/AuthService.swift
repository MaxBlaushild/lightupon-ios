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
    func setToken(token: String) {
        do {
            
            try Locksmith.updateData(["token": token], forUserAccount: "myUserAccount")
            
        } catch {
            
            print("whoops!")
            
        }
    }
    
    func setFacebookId(facebookId: String) {
        do {
            
            try Locksmith.updateData(["facebookId": facebookId], forUserAccount: "myFacebookAccount")
            
        } catch {
            
            print("whoops!")
            
        }
    }
    
    func getToken() -> String {
        var token = ""
        if let tokenWrapper = Locksmith.loadDataForUserAccount("myUserAccount") as? Dictionary<String, String> {
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
            
            try Locksmith.deleteDataForUserAccount("myUserAccount")
            
        } catch {
            
        }
    }
    
    func getFacebookId() -> String {
        let idWrapper = Locksmith.loadDataForUserAccount("myFacebookAccount")!
        
        let facebookId = idWrapper["facebookId"] as! String
        
        return facebookId
    }
    
    func userIsLoggedIn() -> Bool {
        
        let token = Locksmith.loadDataForUserAccount("myUserAccount")
        
        if token != nil && FBSDKAccessToken.currentAccessToken() != nil {
            return true
        } else {
            return false
        }
    }
    
    deinit {
        print("i am dead")
    }

}
