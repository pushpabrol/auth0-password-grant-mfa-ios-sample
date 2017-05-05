//
//  ViewController.swift
//  Auth0Mfa
//
//  Created by Pushp Abrol on 4/14/17.
//  Copyright © 2017 Pushp Abrol. All rights reserved.
//

import UIKit
import Auth0
import SimpleKeychain
import Alamofire

extension DataRequest {
    public func LogRequest() -> Self {
        //Your logic for logging
        return self
    }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}

class ViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        //textField code
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func loginButton(_ sender: Any) {
        
        let oAuthEndpoint: String = "https://".appending(Application.sharedInstance.domain!).appending("/oauth/token");
        let authRequest = ["realm":Application.sharedInstance.realm,"audience":Application.sharedInstance.API_AUDIENCE,"client_id":Application.sharedInstance.clientId,"password":password.text!,"grant_type":"http://auth0.com/oauth/grant-type/password-realm","scope":"openid profile email offline_access","username":username.text!] as! Dictionary<String,String>
        
        
        
        Alamofire.request(oAuthEndpoint , method: .post, parameters: authRequest, encoding: JSONEncoding.default)
            .LogRequest()
            .responseJSON { response in
                guard response.result.error == nil else {
                    print(response.result.error!)
                    
                    return
                }
                
                // make sure we got JSON and it's a dictionary
                guard let json = response.result.value as? [String: AnyObject] else {
                    print("didn't get todo object as JSON from API")
                    return
                }
                
                if((json["error"]) != nil)
                {
                    let error = json["error"] as! String
                    
                    if(error == "mfa_required")
                    {
                        
                        let mfa_token = json["mfa_token"] as! String
                        
                        self.challengeRequest(mfa_token: mfa_token)
                        
                    }
                    else
                    {
                        let alertController = UIAlertController(title: "Error", message: json["error_description"] as? String, preferredStyle: UIAlertControllerStyle.alert)
                        
                        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default)
                        {
                            (result : UIAlertAction) -> Void in
                            
                        }
                        alertController.addAction(okAction)
                        self.present(alertController, animated: true, completion: nil)
                    }
                }
                else
                {
                    Application.sharedInstance.json = json
                    self.performSegue(withIdentifier: "enterMFACode", sender: self)
                    
                }
                
                
        }
        
    }
    
    func challengeRequest(mfa_token:String) -> Void {
        
        let url: String = "https://".appending(Application.sharedInstance.domain!).appending("/mfa/challenge");
        let challengeRequest = ["challenge_type":"oob otp","client_id":Application.sharedInstance.clientId,"mfa_token":mfa_token] as! Dictionary<String,String>
        
        
        Alamofire.request(url , method: .post, parameters: challengeRequest, encoding: JSONEncoding.default)
            .LogRequest()
            .responseJSON { response in
                guard response.result.error == nil else {
                    print(response.result.error!)
                    
                    return
                }
                
                // make sure we got JSON and it's a dictionary
                guard let json = response.result.value as? [String: AnyObject] else {
                    print("didn't get object as JSON from API")
                    return
                }
                if(json["error"] == nil)
                {
                    let challenge_type = json["challenge_type"] as! String
                    Application.sharedInstance.challengeType = challenge_type
                    if(challenge_type == "otp")
                    {
                        Application.sharedInstance.mfa_token = mfa_token
                        self.performSegue(withIdentifier: "enterMFACode", sender: self)
                        
                    }
                    if(challenge_type == "oob")
                    {
                        
                        if(json["binding_method"] != nil ) {
                            Application.sharedInstance.bindingMethod = json["binding_method"]! as? String
                        }
                        else
                        {
                            Application.sharedInstance.bindingMethod = nil
                        }
                        Application.sharedInstance.mfa_token = mfa_token
                        Application.sharedInstance.oobCode = json["oob_code"]! as? String
                        self.performSegue(withIdentifier: "enterMFACode", sender: self)
                        
                    }
                }
                else
                {
                    print(json)
                    
                    let alertController = UIAlertController(title: "Error", message: json["error_description"] as? String, preferredStyle: UIAlertControllerStyle.alert)
                    
                    let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default)
                    {
                        (result : UIAlertAction) -> Void in
                        
                    }
                    alertController.addAction(okAction)
                    self.present(alertController, animated: true, completion: nil)
                }
                
                
                
        }
        
        
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        //Application.sharedInstance.keychainService.deleteEntry(forKey: "refreshToken")
        // Do any additional setup after loading the view, typically from a nib.
        
        if(Application.sharedInstance.keychainService.string(forKey: "refreshToken") != nil)
        {
        self.tryLoginWithRefreshToken()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tryLoginWithRefreshToken()
    {
        let oAuthEndpoint: String = "https://".appending(Application.sharedInstance.domain!).appending("/oauth/token");
        let authRequest = ["client_id":Application.sharedInstance.clientId,"grant_type":"refresh_token","refresh_token":Application.sharedInstance.keychainService.string(forKey: "refreshToken")!] as! Dictionary<String,String>
        
        Alamofire.request(oAuthEndpoint , method: .post, parameters: authRequest, encoding: JSONEncoding.default)
            .LogRequest()
            .responseJSON { response in
                guard response.result.error == nil else {
                    print(response.result.error!)
                    
                    return
                }
                
                // make sure we got JSON and it's a dictionary
                guard let json = response.result.value as? [String: AnyObject] else {
                    print("didn't get todo object as JSON from API")
                    return
                }
                print(json)
                if((json["error"]) != nil)
                {
                    let error = json["error"] as! String
                    
                    if(error == "mfa_required")
                    {
                        
                        let mfa_token = json["mfa_token"] as! String
                        
                        self.challengeRequest(mfa_token: mfa_token)
                        
                    }
                    else
                    {
                        let alertController = UIAlertController(title: "Error", message: json["error_description"] as? String, preferredStyle: UIAlertControllerStyle.alert)
                        
                        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default)
                        {
                            (result : UIAlertAction) -> Void in
                            
                        }
                        alertController.addAction(okAction)
                        self.present(alertController, animated: true, completion: nil)
                    }
                }
                else
                {
                    Application.sharedInstance.json = json
                    self.performSegue(withIdentifier: "enterMFACode", sender: self)
                    
                }
                
                
        }
    }
    
    
}

