//
//  Application.swift
//  Auth0Mfa
//
//  Created by Pushp Abrol on 4/15/17.
//  Copyright © 2017 Pushp Abrol. All rights reserved.
//

import Foundation
class Application {
    
    static var sharedInstance = Application()
    
    var clientId: String?
    var domain : String?
    var API_AUDIENCE : String?
    var realm : String?
    var bindingMethod: String?
    var oobCode: String?
    var mfa_token: String?
    var json: [String: AnyObject]?
    var challengeType: String?
    
    private init() {
        let path = Bundle.main.path(forResource: "Auth0", ofType: "plist")
        let dict = NSDictionary(contentsOfFile: path!)
        self.clientId = dict!.object(forKey: "clientId") as? String
        self.domain = dict!.object(forKey: "domain") as? String
        self.API_AUDIENCE = dict!.object(forKey: "audience") as? String
        self.realm = dict!.object(forKey: "realm") as? String
        
    }
    
    
    
    
}




